class ApiKey < ActiveRecord::Base
  attr_accessor :token

  belongs_to :user

  validates :user, presence: true, uniqueness: {:scope => [:client, :server]}
  validates :digest, presence: true
  validates :client, presence: true
  validates :server, presence: true

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def authenticated?(token)
    BCrypt::Password.new(digest).is_password?(token)
  end

  def generate_token
    self.token = SecureRandom.urlsafe_base64
    self.digest = self.class.digest(self.token)
  end

  def set_expiry_date
    self.expires_at = 30.days.from_now
  end

  def set_last_access_date
    self.last_access_at = DateTime.now
  end

  def is_expired?
    return self.expires_at <= Time.now ? true : false
  end

end
