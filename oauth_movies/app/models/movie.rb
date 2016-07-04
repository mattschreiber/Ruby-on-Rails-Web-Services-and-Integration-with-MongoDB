class Movie
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :last_modifier, type: String
end
