class Racer
	
	include ActiveModel::Model

	attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

	def initialize (params={})
		@id = params[:_id].nil?  ? params[:id] : params[:_id].to_s
		@number = params[:number].to_i
		@first_name = params[:first_name]
		@last_name = params[:last_name]
		@gender = params[:gender]
		@group = params[:group]
		@secs = params[:secs].to_i	
	end

	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client[:racers]
	end

	def self.all (prototype={}, sort={number:1}, skip=0, limit=nil)
		limit.nil? ? self.collection.find(prototype).skip(skip).sort(sort) : self.collection.find(prototype).skip(skip).sort(sort).limit(limit)
	end

	def self.find id
  	if id.is_a? String
  		id = BSON::ObjectId.from_string(id)
		end
		result = self.collection.find(:_id=>id).first

  	if result.nil?
  		return nil
  	else
  		@id = result[:_id].to_s
  		return Racer.new(result)
  	end
	end

	def save
		result=self.class.collection
              .insert_one(_id:@id, number:@number, first_name:@first_name, last_name:@last_name, gender:@gender, group:@group, secs:@secs)
    @id=result.inserted_id
	end
end




