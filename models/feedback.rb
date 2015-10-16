class Feedback < ActiveRecord::Base
  validates_presence_of :contact
  validates_presence_of :content
end
