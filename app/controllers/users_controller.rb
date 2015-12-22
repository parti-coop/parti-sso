class UsersController < ApplicationController
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

  private

  def create_params
    params.require(:user).permit(:nickname, :email,
                                 :password,
                                 :password_confirmation)
  end

  def update_params
    {}
  end

  def correct_user
    @user ||= User.find(params[:id])
    redirect_to(casino.login_path) unless current_user == @user
  end

  def sessions_path
    casino.sessions_path
  end

  def sign_in_as(user)
    data = { authenticator: 'parti_database', user_data: user_data(user) }
    sign_in(data)
  end

  def user_data(user)
    {
      username:  user.send(username_column_option),
      extra_attributes: extra_attributes(user)
    }
  end

  def extra_attributes(user)
    attributes = {}
    extra_attributes_option.each do |attribute_name, database_column|
      attributes[attribute_name] = user.send(database_column)
    end
    attributes
  end

  def username_column_option
    casino_option("username_column") || 'email'
  end

  def extra_attributes_option
    casino_option("extra_attributes") || {}
  end

  def casino_option(name)
    CASino.config[:authenticators].try(:[], "parti_database").try(:[], "options").try(:[], name)
  end
end
