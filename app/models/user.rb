class User < ActiveRecord::Base
  validates :password, length: { minimum: 6 }

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
end
