class CASino::PartiAuthenticator < CASino::ActiveRecordAuthenticator
  def validate(username, password)
    super(username, password) || validate_by_nickname(username, password)
  end

  def load_user_data(username)
    super(username) || load_user_data_by_nickname(username)
  end

  private

  def validate_by_nickname(username, password)
    user = @model.send("find_by_#{@options[:extra_attributes][:nickname]}!", username)
    password_from_database = user.send(@options[:password_column])

    if valid_password?(password, password_from_database)
      user_data(user)
    else
      false
    end
  rescue ActiveRecord::RecordNotFound
    false
  end

  def load_user_data_by_nickname(username)
    user = @model.send("find_by_#{@options[:extra_attributes][:nickname]}!", username)
    user_data(user)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
