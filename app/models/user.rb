class User < ActiveRecord::Base
  MAX_LENGTH_NAME = 50
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MINIMUM_PASSWORD = 6

  validates :name, presence: true, length: { maximum: MAX_LENGTH_NAME }
  validates :email, presence: true, format: { with: EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: MINIMUM_PASSWORD }

  before_save { self.email = email.downcase }
  
  has_secure_password
end
