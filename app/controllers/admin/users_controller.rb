class Admin::UsersController < ApplicationController
  def index
    @users = User.order(:id).all
    authorize @users
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user
    if @user.save
      redirect_to edit_admin_user_path(@user), notice: "User created"
    else
      render :new, alert: "Failed to create user: " + @user.errors.full_messages.join(", ")
    end
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
    params.require(:user).permit(:name, :email, :github_handle, :kind)
  end
end
