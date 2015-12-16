class UsersController < ApplicationController
  before_action :ensure_signed_in,  only: [:edit, :update, :destroy]
  before_action :correct_user,      only: [:edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
  end

  def new
    if signed_in?
      @user = current_user
      render 'edit'
    end

    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      data = { authenticator: 'parti_database', user_data: { username:  @user.email } }
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

  private

  def user_params
    params.require(:user).permit(:nickname, :email,
                                 :password,
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
