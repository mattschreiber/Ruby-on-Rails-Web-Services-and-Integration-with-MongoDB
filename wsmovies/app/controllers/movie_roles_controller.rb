# MovieRole is a nested resource of Movie, see set_movie_role method
# for changes necessary to properly retrieve information

# We must make one more change. The default JSON marshaller definition for our
# nested resource wants to also see timestamp information within the model.
# (`app/views/movie_roles/show.json.jbuilder`)

#To show a simple change to the marshaller can prevent us from making a unreasonable
#change to our model, we have chosen to remove those fields from the marshaller definition
#for this type.
#json.extract! @movie_role, :id, :character, :actor_id


class MovieRolesController < ApplicationController
  before_action :set_movie
  before_action :set_movie_role, only: [:show, :edit, :update, :destroy]

  # GET /movie_roles
  # GET /movie_roles.json
  def index
    @movie_roles = @movie.roles
  end

  # GET /movie_roles/1
  # GET /movie_roles/1.json
  def show
  end

  # GET /movie_roles/new
  def new
    @movie_role = MovieRole.new
  end

  # GET /movie_roles/1/edit
  def edit
  end

  # POST /movie_roles
  # POST /movie_roles.json
  def create
    last_modified=request.env["HTTP_IF_UNMODIFIED_SINCE"]
    fresh_when(@movie)   if last_modified  #get header values if condition supplied
    
    Rails.logger.debug("if_unmodified_since=#{last_modified}, current=#{response.last_modified}")

    if !last_modified || 
       (DateTime.strptime(last_modified,"%a, %d %b %Y %T %z") >= response.last_modified)

      @movie_role = @movie.roles.build(movie_role_params)
      respond_to do |format|
        if @movie_role.save
          fresh_when(@movie)
          format.html { redirect_to @movie, notice: 'Movie role was successfully created.' }
          format.json { render :"movies/show", status: :ok, location: @movie }
        else
          format.html { render :new }
          format.json { render json: @movie_role.errors, status: :unprocessable_entity }
        end
      end
    else
      render nothing: true, status: :conflict
    end
  end

  # PATCH/PUT /movie_roles/1
  # PATCH/PUT /movie_roles/1.json
  def update
    respond_to do |format|
      if @movie_role.update(movie_role_params)
        format.html { redirect_to @movie_role, notice: 'Movie role was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie_role }
      else
        format.html { render :edit }
        format.json { render json: @movie_role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movie_roles/1
  # DELETE /movie_roles/1.json
  def destroy
    @movie_role.destroy
    respond_to do |format|
      format.html { redirect_to movie_roles_url, notice: 'Movie role was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie_role
      #Movie role is nested resource
      # From the output of `rake routes`, we know that
      # :movie_id - is the property supplying the ID of the Movie
      # :id - is the property supplying the ID of the MovieRole within the Movie
      @movie_role = @movie.roles.find_by(:id=>params[:id])
    end

    def set_movie
      @movie = Movie.find(params[:movie_id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_role_params
      params.require(:movie_role).permit(:character, :actor_id)
    end
end
