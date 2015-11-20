class PostView < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  belongs_to :infection

  UNKOWN = 0
  SPREAD = 1
  SKIP = 2
  POST_DELETED = 3
end
