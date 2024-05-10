class Admin::JudgingBreaksController < ApplicationController
  def create
    @break = JudgingBreak.new(judging_break_params)
    authorize @break
    if @break.save
      redirect_to admin_settings_path
    else
      redirect_to admin_settings_path, alert: @break.errors.full_messages.join(", ")
    end
  end

  def update
    @break = JudgingBreak.find(params[:id])
    authorize @break
    if @break.update(judging_break_params)
      redirect_to admin_settings_path
    else
      redirect_to admin_settings_path, alert: @break.errors.full_messages.join(", ")
    end
  end

  def destroy
    @break = JudgingBreak.find(params[:id])
    authorize @break
    if @break.destroy
      redirect_to admin_settings_path
    else
      redirect_to admin_settings_path, alert: @break.errors.full_messages.join(", ")
    end
  end

  private
  def judging_break_params
    params.require(:judging_break).permit(:begins, :ends)
  end
end
