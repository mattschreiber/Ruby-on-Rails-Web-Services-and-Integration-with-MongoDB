Mongo::Logger.logger.level = ::Logger::INFO

class Photo
  include ActiveModel::Model
  
  attr_accessor :id, :location, :contentType, :coordinates, :place
  attr_writer :contents

    #class method to connect to mongo
   def self.mongo_client
    Mongoid::Clients.default
  end

  def self.all (offset=0, limit=nil)
    files=[]
    if limit
      mongo_client.database.fs.find.skip(offset).limit(limit).each { |file| files.push(Photo.new(file)) }
   else
      mongo_client.database.fs.find.skip(offset).each {|file| files.push(Photo.new(file)) }
   end
    return files
  end 

  def self.find(id)
    photo = mongo_client.database.fs.find(id_criteria(id)).first
    photo.nil? ? nil : Photo.new(photo)
  end

  def self.find_photos_for_place(id)
    if id.is_a? String
      id = BSON::ObjectId.from_string(id)
    end
    mongo_client.database.fs.find('metadata.place': id)
  end

  def self.id_criteria id
    {_id:BSON::ObjectId.from_string(id)}
  end
  def id_criteria
    self.class.id_criteria @id
  end

  def initialize (params={})
    Rails.logger.debug {"instantiating GridFsFile #{params}"}
    if params[:_id]  #hash came from GridFS
      @id=params[:_id].to_s
      @location=params[:metadata].nil? ? nil : Point.new(params[:metadata][:location])
      @place = params[:metadata].nil? ? nil : params[:metadata][:place]
    else              #assume hash came from Rails
      @id=params[:id]
      @location=params[:location]
      @place=params[:place]
    end
  end

  def persisted?
    !@id.nil?
  end

  def save

    if @contents
      gps=EXIFR::JPEG.new(@contents).gps
      @location = Point.new(lng: gps.longitude, lat: gps.latitude)
      @contentType = "image/jpeg"
      @contents.rewind #must rewind before call to Gridfs so proper number of bytes stored
    end

      description = {}
      description[:filename]=@filename          if !@filename.nil?
      description[:content_type]=@contentType   if !@contentType.nil?

      description[:metadata] = {}
      description[:metadata][:place] = @place

      description[:metadata][:location]={}

      description[:metadata][:location][:coordinates] = {}
      description[:metadata][:location][:coordinates] = Array.new
      description[:metadata][:location][:coordinates].push(@location.longitude)
      description[:metadata][:location][:coordinates].push(@location.latitude) 

    if persisted?  
      self.class.mongo_client.database.fs.find(id_criteria).update_one(description)
    else        
      if @contents
        Rails.logger.debug {"contents= #{@contents}"}
        grid_file = Mongo::Grid::File.new(@contents.read, description )
        id=self.class.mongo_client.database.fs.insert_one(grid_file)
        @id=id.to_s
        Rails.logger.debug {"saved gridfs file #{id}"}
        @contents.rewind
        @id
      end
    end  
  end # end save

  def contents
    Rails.logger.debug {"getting gridfs content #{@id}"}
    f=self.class.mongo_client.database.fs.find_one(id_criteria)
    if f 
      buffer = ""
      f.chunks.reduce([]) do |x,chunk| 
          buffer << chunk.data.data 
      end
      return buffer
    end 
  end # end contents

  def destroy
    Rails.logger.debug {"destroying gridfs file #{@id}"}
    self.class.mongo_client.database.fs.find(id_criteria).delete_one
  end

  def find_nearest_place_id (max_meters)
    place = Place.near(@location, max_meters).limit(1).projection(_id:1).first
    place.nil? ? nil : place[:_id]
  end

  def place
    #convert @place to string because that is what Place.find expects

    @place.nil? ? nil : Place.find(@place.to_s)
  end

  def place=(params)
    #can be BSON::ObjectID, String or Place object
    if params.is_a? Place
      @place = BSON::ObjectId.from_string(params.id)
    elsif params.is_a? String
      @place = BSON::ObjectId.from_string(params)
    else
      @place = params
    end
  end
end


# 5.times {photo=Photo.new; photo.contents=File.open('./db/image1.jpg','rb');photo.save}
