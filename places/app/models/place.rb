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

  def initialize (params)
    @id = params[:_id].to_s
    @formatted_address = params[:formatted_address]
    @location = Point.new(params[:geometry][:location])
    @address_components = Array.new
    params[:address_components].each {|e| @address_components.push(AddressComponent.new(e))}

    # params[:address_components].each {|r| @address_components.push(r)}
  end

end
