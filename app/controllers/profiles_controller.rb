class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_username

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, success: #後ほど記載します→t('profile.update.success')
    else
      flash.now[:error] = #後ほど記載します→t('profile.update.error')
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_username
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
