# The Post Controller
class PostsController < ApplicationController
  before_filter -> { find_post(:id) }, only: [:show, 
                                              :edit, 
                                              :update, 
                                              :destroy]

  before_filter -> { find_posts_by_keyword }, only: :search 

  def index
    @posts = Post.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end

  def edit
    @post
  end

  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html do
          redirect_to @post, notice: 'Post was successfully created.'
        end

        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: 'new' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html do
          redirect_to @post, notice: 'Post was successfully updated.'
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json do
          render json: @post.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      @post.destroy
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  def search
    respond_to do |format|
      format.html
    end
  end

  private
  
  def find_posts_by_keyword
    @posts = Post.where('title LIKE ?', "%#{params[:keyword]}%").all 
  end
end
