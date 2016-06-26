Mongo::Logger.logger.level = ::Logger::INFO

class Point

	attr_accessor :longitude, :latitude

	def initialize(longitude, latitude)
		@longitude = longitude
		@latitude = latitude
	end

	def mongoize
		{"type":"Point", "coordinates":[@longitude, @latitude]}
	end

	def self.demongoize(hash)
		if hash.nil?
			nil
		else
			Point.new(hash[:coordinates][0], hash[:coordinates][1])
		end
	end

	def self.mongoize(params)
		if params.is_a? Point
			params.mongoize
		else #GeoJSON hash i.e. {:type=>"Point", :coordinates=>[0, 1]}
			params
		end
	end

	def self.evolve(params)
		if params.is_a? Point
			params.mongoize
		else #GeoJSON hash i.e. {:type=>"Point", :coordinates=>[0, 1]}
			params
		end
	end

end