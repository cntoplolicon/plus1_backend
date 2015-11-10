class Post < ActiveRecord::Base
  belongs_to :user
  has_many :post_pages, -> { order :order }
  has_many :comments, -> { order :created_at }
  has_many :bookmarks

  attr_accessor :bookmarked
end
