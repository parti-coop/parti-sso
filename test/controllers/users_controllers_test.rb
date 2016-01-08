require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  tests UsersController

  USER_EMAIL = 'user@email.com'
  USER_NICKNAME = 'nick'

  test 'should add username to session after sign_up' do
    create_user
    assert_equal USER_EMAIL, session[:cas_username]
  end

  test 'should sign_in after sign_up' do
    @controller.expects(:sign_in).once.with({ authenticator: 'parti_database',
      user_data: {
        username:  USER_EMAIL,
        extra_attributes: {'nickname' => USER_NICKNAME}
      }
    })
    begin
      create_user
    rescue ActionView::MissingTemplate => e
    end
  end

  focus
  test 'should sign_in for edit' do
    get(:edit)

    assert_redirected_to @controller.casino.login_path
  end

  def create_user
    post(:create, user: { nickname: USER_NICKNAME, email: USER_EMAIL,
                          password: 'tset!x333',
                          password_confirmation: 'tset!x333' })
  end
end
