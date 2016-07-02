class Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String

  embeds_many :roles, class_name: "MovieRole"
end


# response = MoviesWS.post("/movies", :body=>{:movie=>{:id=>"12347", :title=>"rocky27"}}.to_json,
# :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/vnd.myorgmovies.v2+json"})