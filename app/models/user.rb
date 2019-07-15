class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: :follower_id, dependent: :destroy
  has_many :reverse_relationships, foreign_key: :followed_id,
           class_name: "Relationship", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :followers, through: :reverse_relationships, source: :follower

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

  def feed
    microposts
  end

  def following? other_user
    relationships.find_by(followed_id: other_user.id)
  end

  def follow! other_user
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow! other_user
    relationships.find_by(followed_id: other_user.id).destroy
  end

  private

  def create_remember_token
    self.remember_token = User.digest User.new_remember_token
  end
end
