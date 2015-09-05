class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_pages, -> { order :order }
  has_many :comments
  has_many :root_comments, {foreign_key: :post_id}, -> { where(root_comment_id: nil) }
  has_many :likes
end
