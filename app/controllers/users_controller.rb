# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user
    if @user.update(user_params)
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in(@user, scope: :user)
      redirect_to edit_user_registration_url, notice: t('devise.passwords.updated')
    else
      render :edit_password
    end
  end

  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.require(:user).permit(:password, :password_confirmation)
  end
end
