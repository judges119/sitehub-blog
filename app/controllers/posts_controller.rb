class PostsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :edit, :create, :update, :destroy]
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
    if current_user == User.first && !current_user.try(:admin?) && User.count == 1
      current_user.update_attribute :admin, true
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    if author_exists = User.where(:id => @post.user_id).first
      if current_user == author_exists || current_user.try(:admin?)
      else
        render :show
      end
    else
      if current_user.try(:admin?)
      else
        render :show
      end
    end
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    if author_exists = User.where(:id => @post.user_id).first
      if current_user == author_exists || current_user.try(:admin?)
        respond_to do |format|
          if @post.update(post_params)
            format.html { redirect_to @post, notice: 'Post was successfully updated.' }
            format.json { render :show, status: :ok, location: @post }
          else
            format.html { render :edit }
            format.json { render json: @post.errors, status: :unprocessable_entity }
          end
        end
      else
        render :show
      end
    else
      if current_user.try(:admin?)
        if @post.update(post_params)
          redirect_to @post, notice: 'Post was successfully updated.'
        else
          render :edit
        end
      else
        render :show
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    if author_exists = User.where(:id => @post.user_id).first
      if current_user == author_exists || current_user.try(:admin?)
        @post.destroy
        respond_to do |format|
          format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
          format.json { head :no_content }
        end
      else
        render :show
      end
    else
      if current_user.try(:admin?)
        @post.destroy
        redirect_to posts_url, notice: 'Post was successfully destroyed.'
      else
        render :show
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :content, :user_id)
    end
end
