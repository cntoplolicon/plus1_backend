class ActiveInfection < ActiveRecord::Base
  belongs_to :user
  belongs_to :infection
end
