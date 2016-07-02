class MovieRole
  include Mongoid::Document
  field :character, type: String

  embedded_in :movie, touch: true
  belongs_to :actor
end

# response=MoviesWS.post("/movies/12347/roles",
# :body=>{:movie_role=>{:id=>"1", :character=>"challenger"}}.to_json,
# :headers=>{"Content-Type"=>"application/json", "Accept"=>"application/json",
# "If-UnModified-Since"=>last_modified})