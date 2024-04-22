class Admin::UsersController < ApplicationController
  def index
    @users = if params[:role]
      User.where(kind: params[:role]).order(:id).all
    else
      User.order(:id).all
    end
    authorize @users
    @users = @users.decorate
  end

  def new
    @user = User.new
    if params[:role]
      @user.kind = params[:role]
    end
    authorize @user
    @user = @user.decorate
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
    @user = @user.decorate
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    @user.update(user_params)
    redirect_to edit_admin_user_path(@user), notice: "User updated"
  end

  def destroy
    @user = User.find(params[:id])
    authorize @user
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted"
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :github_handle, :kind)
  end
end
