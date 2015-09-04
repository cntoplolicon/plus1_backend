require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :resetting_password
  attr_reader :password

  has_secure_password validations: false

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_format_of :username, with: /\A\d{11}\z/
  validates_presence_of :password, if: :resetting_password
  validates_format_of :password, with: /\A[ -~]{6,20}\z/, if: :resetting_password
  validates_presence_of :nickname, :can_infect, :infection_index

  has_many :posts, -> { order :created_at }
  has_many :infections, -> { order :created_at }
  has_many :active_infections, -> { order :created_at }

  def authenticate(password)
    ::BCrypt::Password.new(password_digest) == password
  end

  def password=(new_password)
    @password = new_password
    self.password_digest = ::BCrypt::Password.create(@password)
  end
end
