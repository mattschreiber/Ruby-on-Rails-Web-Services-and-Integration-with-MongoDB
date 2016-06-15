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

  def initialize (params)
    @id = params[:_id].to_s
    @formatted_address = params[:formatted_address]
    @location = Point.new(params[:geometry][:location])
    @address_components = Array.new
    params[:address_components].each {|e| @address_components.push(AddressComponent.new(e))}

    # params[:address_components].each {|r| @address_components.push(r)}
  end

end
