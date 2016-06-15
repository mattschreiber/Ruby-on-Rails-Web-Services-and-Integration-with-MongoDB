class Place
  include Mongoid::Document

  attr_accessor :id, :formatted_address, :location, :address_components
  # @address_components = Array.new()
  
  def self.mongo_client
  	Mongoid::Clients.default
  end

  def self.collection
  	self.mongo_client[:places]
  end

  def self.load_all(file_path)
  	file = File.read(file_path)
  	hash = JSON.parse(file)
  	self.collection.insert_many(hash)
  end

  def self.delete_many
  	self.collection.delete_many
	end

  def self.find_by_short_name (short_name)
    collection.find({'address_components.short_name': short_name})
  end

  def self.to_places (mongo_view)
    places = Array.new
    mongo_view.each {|r| places.push(Place.new(r))} 
    return places
  end

  def self.find(id)
    place = collection.find({_id: BSON::ObjectId.from_string(id)}).first
    place.nil? ? nil : Place.new(place)
  end

  def self.all(offset=0, limit=nil)
    places = Array.new
    if limit
      collection.find.skip(offset).limit(limit).each {|place| places.push(Place.new(place))}
    else
      collection.find.skip(offset).each {|place| places.push(Place.new(place))}
    end
    return places
  end

  def self.get_address_components(sort={}, offset=0, limit=nil)
    if sort.empty? #apply no filters
      collection.find.aggregate([{:$unwind=>'$address_components'},
      {:$project=>{_id:1, formatted_address:1, 'geometry.geolocation':1, address_components:1}}])
    elsif limit #limit results
      collection.find.aggregate([{:$unwind=>'$address_components'},
      {:$project=>{_id:1, formatted_address:1, 'geometry.geolocation':1, address_components:1}}, 
      {:$sort=>sort}, 
      {:$skip=>offset}, {:$limit=>limit}])
    else #no limit
      collection.find.aggregate([{:$unwind=>'$address_components'},
      {:$project=>{_id:1, formatted_address:1, 'geometry.geolocation':1, address_components:1}}, 
      {:$sort=>sort}, 
      {:$skip=>offset}])
    end
  end

  def self.get_country_names
    collection.find.aggregate([{:$project=>{'address_components.long_name':1, 'address_components.types':1}},
      {:$unwind=>'$address_components'},
      {:$unwind=>'$address_components.types'},
      {:$match=>{'address_components.types':'country'}}, 
      {:$group=>{_id:{long_name:'$address_components.long_name'}}}]).to_a.map {|h| h[:_id][:long_name]}
  end

  def self.find_ids_by_country_code(country_code)
    collection.find.aggregate([{:$match=>{'address_components.short_name':country_code}},
      {:$project=>{_id:1}}]).to_a.map {|code| code[:_id].to_s}
  end

  def self.create_indexes
    collection.indexes.create_one({'geometry.geolocation' => Mongo::Index::GEO2DSPHERE})
  end

  def self.remove_indexes
    collection.indexes.drop_one("geometry.geolocation_2dsphere")
  end

  def initialize (params)
    @id = params[:_id].to_s
    @formatted_address = params[:formatted_address]
    @location = Point.new(params[:geometry][:location])
    @address_components = Array.new
    params[:address_components].each {|e| @address_components.push(AddressComponent.new(e))}

    # params[:address_components].each {|r| @address_components.push(r)}
  end

  def destroy
    self.class.collection.find({_id: BSON::ObjectId.from_string(id)}).delete_one
  end

end
