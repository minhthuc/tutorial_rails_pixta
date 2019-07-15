class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy

  MAX_LENGTH_NAME = 50
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MINIMUM_PASSWORD = 6

  validates :name, presence: true, length: { maximum: MAX_LENGTH_NAME }
  validates :email, presence: true, format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: MINIMUM_PASSWORD }

  before_save { self.email = email.downcase }
  before_create :create_remember_token

  has_secure_password

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.digest token
    Digest::SHA1.hexdigest token.to_s
  end

  private

  def create_remember_token
    self.remember_token = User.digest User.new_remember_token
  end
end
