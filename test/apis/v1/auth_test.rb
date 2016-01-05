require 'test_helper'

class SessionsTest < ActionDispatch::IntegrationTest
  def setup
    @client = 'uuid'
    @server = 'host'
    @one = users(:one)
  end

  def authenticate
    get "/api/v1/authenticate?username=#{@one.nickname}&password=12345678&client=#{@client}&server=#{@server}"
    result = JSON.parse(@response.body)
    assert result.has_key?("token")
    assert_equal @one.email, result["email"]

    result["token"]
  end

  def certify(token, email: @one.email, client: @client, server: @server)
    get "/api/v1/certify?email=#{email}&token=#{token}&client=#{client}&server=#{server}"
    result = JSON.parse(@response.body)
    refute result.has_key?("token")
    assert (result.has_key?("error") or result.has_key?("expires_at"))

    result
  end

  test 'authorize and certify' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert api_key.authenticated?(token)

    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    result = certify(token)
    assert_equal previous_expires_at.to_json, result["expires_at"].to_json

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert_equal previous_expires_at, api_key.expires_at
    refute_equal previous_last_access_at, api_key.last_access_at

    assert_equal @one.email, result["user_data"]["username"]
  end

  test 'reauthenticate' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    # retry to auth
    new_token = authenticate

    @one.reload
    refute_equal token, new_token
    api_key = @one.api_keys.find_by(client: @client)
    assert api_key.authenticated?(new_token)
    refute_equal previous_expires_at, api_key.expires_at
    refute_equal previous_last_access_at, api_key.last_access_at
  end

  test 'with invalid password' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    get "/api/v1/authenticate?username=#{@one.nickname}&password=invalid&client=#{@client}&server=#{@server}"
    result = JSON.parse(@response.body)

    assert_equal "invalid credentials", result["error"]
    assert_equal 401, response.status

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert_equal previous_expires_at, api_key.expires_at
    assert_equal previous_last_access_at, api_key.last_access_at
  end

  test 'invalid token' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert api_key.authenticated?(token)
    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    result = certify(token + "XX")
    assert_equal "invalid token", result["error"]
    assert_equal 401, response.status

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert_equal previous_expires_at, api_key.expires_at
    assert_equal previous_last_access_at, api_key.last_access_at
  end

  test 'invalid email' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert api_key.authenticated?(token)
    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    result = certify(token, email: @one.email + "XX")
    assert_equal "invalid email", result["error"]
    assert_equal 401, response.status

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert_equal previous_expires_at, api_key.expires_at
    assert_equal previous_last_access_at, api_key.last_access_at
  end

  test 'invalid client' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert api_key.authenticated?(token)
    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    result = certify(token, client: @client + "XX")
    assert_equal "uncertified", result["error"]
    assert_equal 401, response.status

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert_equal previous_expires_at, api_key.expires_at
    assert_equal previous_last_access_at, api_key.last_access_at
  end

  test 'invalid server' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert api_key.authenticated?(token)
    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    result = certify(token, server: @server + "XX")
    assert_equal "uncertified", result["error"]
    assert_equal 401, response.status

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert_equal previous_expires_at, api_key.expires_at
    assert_equal previous_last_access_at, api_key.last_access_at
  end

  test 'exipred' do
    token = authenticate

    @one.reload
    api_key = @one.api_keys.find_by(client: @client)
    assert api_key.authenticated?(token)
    previous_expires_at = api_key.expires_at
    previous_last_access_at = api_key.last_access_at

    travel 40.days do
      result = certify(token)
      assert_equal "expired", result["error"]
      assert_equal 401, response.status

      @one.reload
      api_key = @one.api_keys.find_by(client: @client)
      assert_equal previous_expires_at, api_key.expires_at
      assert_equal previous_last_access_at, api_key.last_access_at
    end
  end
end
