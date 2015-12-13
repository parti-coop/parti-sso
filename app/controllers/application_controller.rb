class ApplicationController < ActionController::Base
  include CASino::SessionsHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action do
    if sign_in_action? and signed_in?
      session[:cas_username] = current_user.username
    elsif sign_out_action? and !signed_in?
      session.delete :cas_username
    end
  end

  private

  def sign_in_action?
    (controller_name == 'sessions' and action_name == 'new') or
    (controller_name == 'sessions' and action_name == 'create') or
    (controller_name == 'users' and action_name == 'create')
  end

  def sign_out_action?
    controller_name == 'sessions' and action_name == 'logout'
  end
end
