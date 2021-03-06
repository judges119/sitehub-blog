class UsersController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if current_user.try(:admin?)
      if current_user == @user && params[:user][:admin] == '0' && User.where(:admin => true).count == 1
        render :show
      else
        if @user.update(user_params)
          redirect_to user_path(@user), notice: 'User was successfully updated.'
        else
          render :show
        end
      end
    else
      render :show
    end
  end
  
  def destroy
    if current_user.try(:admin?)
      @user = User.find(params[:id])
      if current_user == @user && User.where(:admin => true).count == 1
        render :show
      else
        @user.destroy
        redirect_to users_path
      end
    else
      render :show
    end
  end
  
  private
    def user_params
      params.require(:user).permit(:admin)
    end
end
