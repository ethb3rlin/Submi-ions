class UsersController < ApplicationController
  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update(user_params)
      redirect_to root_path
    else
      render :edit, alert: 'There was an error updating your profile: ' + @user.errors.full_messages.join(', ')
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email)
  end
end
