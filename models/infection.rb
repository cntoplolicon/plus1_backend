class Infection < ActiveRecord::Base
  belongs_to :user
  belongs_to :post
  has_one :post_view
end
