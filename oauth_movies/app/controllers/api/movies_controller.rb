module Api
  class MoviesController < Api::BaseController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  def index
    respond_with Movie.all
  end
  def show
    respond_with @movie
  end
  def create
    respond_with Movie.create(movie_params)
  end
  def update
    respond_with @movie.update(movie_params)
  end
  def destroy
    respond_with @movie.destroy
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])

      rescue Mongoid::Errors::DocumentNotFound => e
      respond_to do |format|
        format.json { render json: {msg:"movie[#{params[:id]}] not found"}, status: :not_found }
      end
    end
    def movie_params
      params.require(:movie).permit(:id, :title)
    end
  end
end