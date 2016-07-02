# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Mongo::Logger.logger.level = ::Logger::DEBUG
require 'pp'
Movie.destroy_all
Actor.destroy_all
MovieRole.destroy_all
movie=Movie.create!(:id=>"12345", :title=>"rocky25")
# movie1 = Movie.create(:id=>"12346", :title=>"rocky26")
actor=Actor.create!(:id=>"100",:name=>"sylvester stallone")
rocky=movie.roles.create!(:id=>"0",:character=>"rocky")
rocky.actor=actor
rocky.save