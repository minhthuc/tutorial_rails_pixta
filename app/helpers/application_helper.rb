module ApplicationHelper
  def full_title page_title
    base_title = "Ruby on Rails Tutorial Sample App"
    page_title.empty? ? base_title : "#{base_title} | #{page_title}"
  end

  def user_followed user
    current_user.relationships.find_by followed_id: user.id
  end

  def new_model_follow user
    current_user.relationships.build followed_id: user.id
  end
end
