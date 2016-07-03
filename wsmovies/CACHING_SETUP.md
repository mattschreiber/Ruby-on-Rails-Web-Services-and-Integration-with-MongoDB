## Assembly

This section covers the basics of how the application was assembled.
The unique difference this application has is thar it logs activity
with the model in a separate collection from the model under test.

### Core Application

1. Create a new application

    ```shell
    $ rails new caching-movies
    $ cd caching-movies
    ```

2. Update Gemfile, run bundle, install Mongoid, and start server

    ```ruby
    # Gemfile
    gem 'mongoid', '~>5.0.0'
    gem 'httparty'
    ```
    ```ruby
    # config/application.rb
    Mongoid.load!("./config/mongoid.yml")
    ```
    ```shell
    $ bundle
    $ rails s
    ```

### Create the Models

1. Create the model scaffolding

    ```rails
    $ rails g scaffold Movie id title updated_at
    $ rails g model MovieAccess created_at accessed_by action
    ```

2. Update the model classes.

    ```ruby
    class Movie
      include Mongoid::Document
      include Mongoid::Timestamps::Updated
      field :id, type: String
      field :title, type: String

      has_many :movie_accesses 
    end
    ```
    ```ruby
    class MovieAccess
      include Mongoid::Document
      include Mongoid::Timestamps::Created
      field :accessed_by, type: String
      field :action, type: String

      belongs_to :movie
    end
    ```
3. Verify data model using the rails console. We should be able to create a movie
and store access to that movie. We will use this to keep track of impact of changes
made.

```ruby
> movie=Movie.create(:id=>"12345", :title=>"rocky25")
> movie.movie_accesses.create(:accessed_by=>"123",:action=>"created")

> pp Movie.find(movie.id).attributes
{"_id"=>"12345", "title"=>"rocky25", "updated_at"=>2016-01-11 00:02:03 UTC}
 => {"_id"=>"12345", "title"=>"rocky25", "updated_at"=>2016-01-11 00:02:03 UTC} 

> pp Movie.find(movie.id).movie_accesses.pluck(:created_at, :accessed_by, :action)
[[2016-01-11 00:02:09 UTC, "123", "created"]]
```

4. Fix the JSON view of the movie

    ```ruby
    json.extract! @movie, :id, :title, :created_at
    ```

5. Update the Movies controller to add a MovieAccess for each time the movie
is grabbed from the database and why.

    ```ruby
    # app/controllers/movies_controller.rb
      def show
        @movie.movie_accesses.create(:action=>"show")
      end
      def create
        @movie = Movie.new(movie_params)

        respond_to do |format|
          if @movie.save
            @movie.movie_accesses.create(:action=>"create")

      def update
        respond_to do |format|
          if @movie.update(movie_params)
            @movie.movie_accesses.create(:action=>"create")

      def destroy
        @movie.movie_accesses.create(:action=>"destroy")
        @movie.destroy
    ```

6. Update the ApplicationController to permit WS interaction.

    ```ruby
    # app/controllers/application_controller.rb
    class ApplicationController < ActionController::Base
      # Prevent CSRF attacks by raising an exception.
      # For APIs, you may want to use :null_session instead.
      #protect_from_forgery with: :exception
      protect_from_forgery with: :null_session
    end
    ```

7. Test out WS access and controller functionality

    ```ruby
    > response=HTTParty.post("http://localhost:3000/movies",:body=>{:movie=>{:id=>"123456", :title=>"rocky25"}})

    > pp Movie.find("123456").attributes
    D | {"find"=>"movies", "filter"=>{"_id"=>"123456"}}
    {"_id"=>"123456", "title"=>"rocky25", "updated_at"=>2016-01-11 00:13:01 UTC}

    > pp Movie.find("123456").movie_accesses.pluck(:created_at, :accessed_by, :action)
    [[2016-01-11 00:13:01 UTC, nil, "create"],
     [2016-01-11 00:13:01 UTC, nil, "show"]]
    ```

8. Create clones of the Movies controller (MoviePages and MovieActions). 
Adjust the generated views s that they reference the Movie model class and 
not MovieAction and MoviePage.

## Last Updated: 2016-01-12
