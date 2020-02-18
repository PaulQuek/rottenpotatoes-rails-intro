class MoviesController < ApplicationController
  helper_method :all_ratings, :saved_ratings
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

# Determines which rating buttons were pushed
  def saved_ratings
    if params[:ratings].nil?
      if session[:saved_ratings].nil?
        @saved_ratings = all_ratings
      else
        @saved_ratings = session[:saved_ratings]
      end
    else
      @saved_ratings = []
      params[:ratings].each_key {|key| @saved_ratings.push(key)}
    end
    session[:saved_ratings] = @saved_ratings
    @saved_ratings
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if session[:saved_sort].nil?
      if params[:ratings].nil?
        if session[:saved_ratings].nil?
          @selected_ratings = all_ratings.each
        else
          @selected_ratings = session[:saved_ratings]
        end   
      else
        @selected_ratings = params[:ratings].each_key
      end
      @movies = Movie.where("upper(rating) in (?)", @selected_ratings)
    elsif session[:saved_sort] == "nameSort"
      redirect_to sort_name_index_path
    elsif session[:saved_sort] == "dateSort"
      redirect_to sort_date_index_path
    end
  end
  
  # Selects all the possibility of ratings  
  def all_ratings
    @all_ratings = Movie.distinct.pluck(:rating)
    @all_ratings = @all_ratings.map(&:upcase)
  end
  
  def sort_by_name_index
    if params[:ratings].nil?
      if session[:saved_ratings].nil?
        @selected_ratings = all_ratings.each
      else
        @selected_ratings = session[:saved_ratings]
      end   
    else
      @selected_ratings = params[:ratings].each_key
    end
    session[:saved_sort] = "nameSort"
    @sort_by_name_movies = Movie.where("upper(rating) in (?)", @selected_ratings).order("title ASC").all
  end

  def sort_by_date_index
    if params[:ratings].nil?
      if session[:saved_ratings].nil?
        @selected_ratings = all_ratings.each
      else
        @selected_ratings = session[:saved_ratings]
      end 
    else
      @selected_ratings = params[:ratings].each_key
    end
    session[:saved_sort] = "dateSort"
    @sort_by_date_movies = Movie.where("upper(rating) in (?)", @selected_ratings).order("release_date ASC").all
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end