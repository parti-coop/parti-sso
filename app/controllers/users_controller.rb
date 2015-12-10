class UsersController < ApplicationController
  include CASino::SessionsHelper

  before_action :ensure_signed_in,  only: [:edit, :update, :destroy]
  before_action :correct_user,      only: [:edit, :update, :destroy]

  def new
    redirect_to(:back) if signed_in?

    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      data = { authenticator: 'ActiveRecord', user_data: { username:  @user.username } }
      sign_in(data)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:username, :password,
                                 :password_confirmation)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(casino.login_path) unless current_user == @user
  end

  def sessions_path
    casino.sessions_path
  end
end
