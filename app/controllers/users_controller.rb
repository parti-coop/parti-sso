class UsersController < ApplicationController
  include Sessionalbe

  before_action :ensure_signed_in,  only: [:edit, :update, :destroy]
  before_action :correct_user,      only: [:destroy]

  def show
    @user = User.find(params[:id])
  end

  def fetch
    key = params[:key]
    @user = User.find_by(email: key) || User.find_by(nickname: key)

    render text: "Not found", status: 404 and return if @user.nil?
    respond_to do |format|
      format.json {
        render json: user_data(@user)
      }
    end
  end

  def new
    if signed_in?
      @user = current_user
      render 'edit'
    end

    @user = User.new
  end

  def create
    @user = User.new(create_params)
    if @user.save
      sign_in_as(@user)
    else
      render 'new'
    end
  end

  def edit
    @user = User.find_by email: current_user.username
    redirect_to(casino.login_path) and return if @user.nil?
  end

  def update
    @user = User.find_by email: current_user.username
    redirect_to(casino.login_path) and return if @user.nil?
    if @user.update_attributes update_params
      sign_in_as(@user)
    else
      render 'edit'
    end
  end

  def image
    @user = User.find_by(nickname: params[:nickname])
    path = @user.try(:image_url) || PictureUploader.new.default_url
    send_file "#{Rails.root}/public#{path}", :disposition => 'inline'
  end

  private

  def create_params
    params.require(:user).permit(:nickname, :email,
                                 :password,
                                 :password_confirmation,
                                 :image)
  end

  def update_params
    params.require(:user).permit(:image)
  end

  def correct_user
    @user ||= User.find(params[:id])
    redirect_to(casino.login_path) unless current_user == @user
  end
end
