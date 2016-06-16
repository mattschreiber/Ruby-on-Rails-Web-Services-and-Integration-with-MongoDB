class Photo
  include ActiveModel::Model
  
  attr_accessor :id, :location, :contentType, :coordinates
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
    else              #assume hash came from Rails
      @id=params[:id]
      @location=params[:location]
    end
  end

  def persisted?
    !@id.nil?
  end

  def save
    if persisted?
      #do nothing
    else
      gps=EXIFR::JPEG.new(@contents).gps
      @location = Point.new(lng: gps.longitude, lat: gps.latitude)
      @contentType = "image/jpeg"
      @contents.rewind #must rewind before call to Gridfs so proper number of bytes stored

      description = {}
      description[:filename]=@filename          if !@filename.nil?
      description[:content_type]=@contentType   if !@contentType.nil?

      description[:metadata] = {}
      description[:metadata][:location]={}

      description[:metadata][:location][:coordinates] = {}
      description[:metadata][:location][:coordinates] = Array.new
      description[:metadata][:location][:coordinates].push(@location.longitude)
      description[:metadata][:location][:coordinates].push(@location.latitude) 
        
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
end
