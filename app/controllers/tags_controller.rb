class TagsController < ApplicationController
  before_filter :authenticate_user!, :only => [:destroy]

  # GET /tags
  def index
    @tags = Tag.all
  end
  
  # GET /tags/1
  def show
    @tag = Tag.find_by_param(params[:id])
  end
  
  # DELETE /tags/1
  def destroy
    @tag = Tag.find_by_param(params[:id])
    if current_user.try(:admin?)
      @tag.destroy
      redirect_to tags_url, notice:  'Tag was successfully destroyed.'
    else
      redirect_to tags_url, notice: 'Tag unsuccessfully destroyed.'
    end
  end
end
