module Sessionalbe
  extend ActiveSupport::Concern

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
