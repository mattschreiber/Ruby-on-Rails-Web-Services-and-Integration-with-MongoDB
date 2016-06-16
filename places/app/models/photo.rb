class Photo
  include ActiveModel::Model
  
  attr_accessor :id, :location
  attr_writer :contents

    #class method to connect to mongo
   def self.mongo_client
    Mongoid::Clients.default
  end

end
