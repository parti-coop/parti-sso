require 'test_helper'


class SessionsControlerTest < ActionController::TestCase
  tests CASino::SessionsController

  USER_EMAIL = 'user@email.com'

  setup do
    @routes = CASino::Engine.routes
    @controller.stubs(:validate_login_credentials).returns({ authenticator: 'parti_database',
      user_data: {
        username:  USER_EMAIL,
        extra_attributes: {'nickname': 'test_nickname'}
      }
    })
    @controller.stubs(:validate_login_ticket).returns()
  end

  test 'log in and out' do
    post(:create)

    assert_equal USER_EMAIL, session[:cas_username]
    session.delete :cas_username

    get(:new)

    assert_equal USER_EMAIL, session[:cas_username]

    get(:logout)

    assert_nil session[:cas_username]
  end
end
