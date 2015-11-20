class Post < ActiveRecord::Base
  DELETED_BY_AUTHOR = 1
  DELETED_BY_ADMIN = 2

  belongs_to :user
  has_many :post_pages, -> { order :order }
  has_many :comments, -> { order :created_at }
  has_many :bookmarks

  attr_accessor :bookmarked

  def deleted?
    !deleted_by.nil?
  end
end
