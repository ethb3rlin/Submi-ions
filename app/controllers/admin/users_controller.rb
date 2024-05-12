class Admin::UsersController < ApplicationController
  def index
    @users = if params[:role]== 'unauthorized'
      User.approval_pending.order(:id).all
    elsif params[:role].present?
      User.where(kind: params[:role]).order(:id).all
    else
      User.order(:id).all
    end.includes(:ethereum_addresses, :hacking_teams)
    authorize @users
    @users = @users.decorate
  end

  def new
    @user = User.new(approved_at: DateTime.now, approved_by: current_user)
    if params[:role] != 'unauthorized'
      @user.kind = params[:role]
    end
    authorize @user
    @user = @user.decorate
  end

  def manually_approve
    @user = User.unscoped.find(params[:user_id])
    authorize @user
    @user.approve_as!(current_user)
    redirect_to @user, notice: "User approved"
  end

  def unapprove
    @user = User.find(params[:user_id])
    authorize @user
    @user.update!(approved_at: nil, approved_by: nil)
    redirect_to @user, notice: "User unapproved"
  end

  def create
    @user = User.unscoped.new(user_params)
    authorize @user
    if @user.save
      redirect_to edit_admin_user_path(@user), notice: "User created"
    else
      render :new, alert: "Failed to create user: " + @user.errors.full_messages.join(", ")
    end
  end

  def edit
    @user = User.unscoped.find(params[:id])
    authorize @user
    @user = @user.decorate
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update(user_params)
      redirect_to edit_admin_user_path(@user), notice: "User updated"
    else
      redirect_to edit_admin_user_path(@user), alert: "Failed to update user: " + @user.errors.full_messages.join(", ")
    end
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
