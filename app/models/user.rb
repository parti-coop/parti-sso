class User < ActiveRecord::Base
  validates :password, length: { minimum: 6 }
  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 50 }
  has_secure_password
end
