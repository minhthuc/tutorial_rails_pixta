class Micropost < ActiveRecord::Base
  MAXIMUM_LENGTH = 140
  belongs_to :user
  validates :content, length: { maximum: MAXIMUM_LENGTH }
end
