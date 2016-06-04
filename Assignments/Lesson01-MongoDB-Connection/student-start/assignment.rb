#require 'bundler/setup'
require 'mongo'
require 'pp'

#Bundler.require

class Solution
  include
  @@db = nil
  Mongo::Logger.logger.level = ::Logger::INFO

  #Implement a class method in the `Solution` class called `mongo_client` that will 
  def self.mongo_client
    @@db = Mongo::Client.new('mongodb://localhost:27017').use('test')
  end

  #Implement a class method in the `Solution` class called `collection` that will
  def self.collection
    #return the `zips` collection
    @coll = @@db[:zips]
    
  end

  #Implement an instance method in the `Solution` class called `sample` that will
  def sample
    #return a single document from the `zips` collection from the database. 
    #This does not have to be random. It can be first, last, or any other document in the collection.
    @@db[:zips].find.first
  end
end

#byebug
db=Solution.mongo_client
p db
zips=Solution.collection
p zips
s=Solution.new
pp s.sample
