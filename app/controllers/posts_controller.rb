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
  def create
    if post_params[:title].squish.downcase.tr(" ","_").gsub(/[^0-9A-Za-z_]/, '') == 'new'
      redirect_to posts_path, notice: 'Post cannot be titled "new".'
    else
      @post = Post.new(post_params)
      @post.url = post_params[:title].squish.downcase.tr(" ","_").gsub(/[^0-9A-Za-z_]/, '')
      @post.tags = ready_tags
      
      if @post.save
        if params[:content][:content]
          params[:content][:content].each do |text|
            content = Content.new
            content.content = text[1]
            content.position = text[0]
            content.post_id = @post.id
            content.save
          end
        end
        if params[:content][:picture]
          params[:content][:picture].each do |picture|
            content = Content.new
            content.picture = picture[1]
            content.position = picture[0]
            content.post_id = @post.id
            content.save
          end
        end

        redirect_to @post, notice: 'Post was successfully created.'
      else
        destroy_orphaned_tags(@post.tags, 0)
        render :new
      end
    end
  end

  # PATCH/PUT /posts/1
  def update
    if post_params[:title].squish.downcase.tr(" ","_").gsub(/[^0-9A-Za-z_]/, '') == 'new'
      render :edit
    else
      destroy_orphaned_tags(@post.tags, 1)
      @post.url = post_params[:title].squish.downcase.tr(" ","_").gsub(/[^0-9A-Za-z_]/, '')
      @post.tags = ready_tags
      
      if author_exists = User.where(:id => @post.user_id).first
        if current_user == author_exists || current_user.try(:admin?)
          if @post.update(post_params)
            redirect_to @post, notice: 'Post was successfully updated.'
          else
            destroy_orphaned_tags(@post.tags, 0)
            render :edit
          end
        else
          render :show
        end
      else
        if current_user.try(:admin?)
          if @post.update(post_params)
            redirect_to @post, notice: 'Post was successfully updated.'
          else
            destroy_orphaned_tags(@post.tags, 0)
            render :edit
          end
        else
          render :show
        end
      end
    end
  end

  # DELETE /posts/1
  def destroy
    if author_exists = User.where(:id => @post.user_id).first
      if current_user == author_exists || current_user.try(:admin?)
        destroy_orphaned_tags(@post.tags, 1)
        @post.destroy
        redirect_to posts_url, notice: 'Post was successfully destroyed.'
      else
        render :show
      end
    else
      if current_user.try(:admin?)
		destroy_orphaned_tags(@post.tags, 1)
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
      @post = Post.find_by_param(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :user_id)
    end
    
    def tag_params
      params.require(:post).permit(:tag_ids)
    end
    
    def content_params
      params.require(:content).permit(:picture)
    end
    
    def ready_tags
      tags = tag_params[:tag_ids].split(/,\s*/)
      tags_ready = []
      tags.each do |tag|
        temp = Tag.find_by_url(tag.squish.downcase.tr(" ","_").gsub(/[^0-9A-Za-z_]/, ''))
        if temp == nil
          temp = Tag.create(name: tag, url: tag.squish.downcase.tr(" ","_").gsub(/[^0-9A-Za-z_]/, ''))
        end
        tags_ready.push(temp)
      end
      tags_ready
    end
    
    def destroy_orphaned_tags(tags, limit)
      tags.each do |tag|
        if (tag.posts.count <= limit)
          tag.destroy
        end
      end
    end
end
