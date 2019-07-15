class Micropost < ActiveRecord::Base
  MAX_LENGTH_CONTENT = 140

  belongs_to :user

  default_scope -> { order('created_at DESC') }

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: MAX_LENGTH_CONTENT }
end
