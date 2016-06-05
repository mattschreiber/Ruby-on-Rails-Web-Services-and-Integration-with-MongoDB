class Racer

	def self.mongo_client
		Mongoid::Clients.default
	end

	def self.collection
		self.mongo_client[:racers]
	end

	def self.all (prototype={}, sort={number:1}, skip=0, limit=nil)

		if limit.nil?
			self.collection.find(prototype).skip(skip).sort(sort)
		else
			self.collection.find(prototype).skip(skip).sort(sort).limit(limit)
		end
		
	end

end
