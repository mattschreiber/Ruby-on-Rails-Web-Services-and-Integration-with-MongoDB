class Photo
  include ActiveModel::Model
  
    #class method to connect to mongo
   def self.mongo_client
    Mongoid::Clients.default
  end

end
