class Placing
	attr_accessor :name, :place

	def initialize(hash)
		@name = hash[:name]
		@place = hash[:place]
	end

	def mongoize
		{name: @name, place: @place}
	end

	def self.demongoize(hash)
		if hash.nil?
			nil
		else
			Placing.new(hash)
		end
	end

	def self.mongoize(hash)
		if hash.is_a? Placing
			hash.mongoize
		else 
			hash
		end
	end

	def self.evolve(hash)
		if hash.is_a? Placing
			hash.mongoize
		else 
			hash
		end
	end

end