require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest
  test 'sign_in with email' do
    CASino::SessionsController.any_instance.stubs(:validate_login_ticket).returns(true)
    post casino.login_path(username: users(:one).email, password: '12345678')
    assert_equal users(:one).email, session[:cas_username]
  end

  test 'sign_in with nickname' do
    CASino::SessionsController.any_instance.stubs(:validate_login_ticket).returns(true)
    post casino.login_path(username: users(:one).nickname, password: '12345678')
    assert_equal users(:one).email, session[:cas_username]
  end
end
