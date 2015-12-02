class Event < ActiveRecord::Base
  validates_presence_of :description

  has_many :event_pages, -> { order :order }
  has_many :posts
end
