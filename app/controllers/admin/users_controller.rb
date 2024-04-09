class Admin::UsersController < ApplicationController
  def index
    @users = User.all
    authorize @users
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    @user.update(user_params)
    redirect_to edit_admin_user_path(@user), notice: "User updated"
  end


  private
  def user_params
    kind = params.keys.intersection(%w{user hacker organizer judge}).first
    params.require(kind).permit(:name, :email, :github_handle, :type)
  end
end
