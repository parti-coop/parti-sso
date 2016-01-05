module API
  module V1
    class Base < Grape::API
      include API::GlobalDefaults
      include API::V1::Defaults

      helpers CASino::AuthenticationProcessor
      helpers Sessionalbe

      desc "Authenticate"
      params do
        requires :username, type: String
        requires :password, type: String
        requires :client, type: String
        requires :server, type: String
      end
      get "authenticate" do
        user_data = validate_login_credentials(permitted_params[:username], permitted_params[:password])
        unless user_data
          status 401
          return { error: 'invalid credentials' }
        end
        user = User.find_by(email: user_data[:user_data][:username])
        api_key = user.api_keys.find_or_initialize_by(client: permitted_params[:client], server: permitted_params[:server])
        api_key.generate_token
        api_key.set_last_access_date
        api_key.set_expiry_date
        api_key.save!

        { token: api_key.token,
          email: user.email }
      end

      desc "Certify"
      params do
        requires :email, type: String
        requires :token, type: String
        requires :client, type: String
        requires :server, type: String
      end
      get "certify" do
        api_key = ApiKey.find_by(client: permitted_params[:client], server: permitted_params[:server])
        if api_key.nil?
          status 401
          { error: "uncertified" }
        elsif api_key.user.email != permitted_params[:email]
          status 401
          { error: "invalid email" }
        elsif !api_key.authenticated?(permitted_params[:token])
          status 401
          { error: "invalid token" }
        elsif api_key.is_expired?
          status 401
          { error: "expired" }
        else
          api_key.set_last_access_date
          api_key.save!

          { api_key_id: api_key.id,
            expires_at: api_key.expires_at,
            user_data: user_data(api_key.user) }
        end
      end
    end
  end
end
