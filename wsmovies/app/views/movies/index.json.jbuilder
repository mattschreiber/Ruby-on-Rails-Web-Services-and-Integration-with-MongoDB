json.array!(@movies) do |movie|
  json.extract! movie, :id, :title, :updated_at
  json.url movie_url(movie, format: :json)
end
