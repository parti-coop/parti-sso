class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token

  VALID_NICKNAME_REGEX = /\A[a-z0-9_]+\z/i
  validates :nickname,
    presence: true,
    format: { with: VALID_NICKNAME_REGEX },
    uniqueness: { case_sensitive: false },
    length: { maximum: 20 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email,
    presence: true,
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, length: { minimum: 6 }, allow_nil: true

  before_save :downcase_email

  mount_uploader :image, PictureUploader

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def password_reset_expired?
    reset_sent_at < 2.days.ago
  end

  private

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def downcase_email
    self.email = email.downcase
  end
end
