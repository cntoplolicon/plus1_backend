require 'bcrypt'

class User < ActiveRecord::Base
  GENDER_UNKNOWN = 0
  GENDER_MALE = 1
  GENDER_FEMALE = 2

  attr_accessor :resetting_password
  attr_reader :password

  has_secure_password validations: false

  validates_presence_of :username
  validates_format_of :username, with: /\A\d{11}\z/
  validates_presence_of :password, if: :resetting_password
  validates_format_of :password, with: /\A[ -~]{6,20}\z/, if: :resetting_password
  validates_presence_of :nickname

  has_many :posts, -> { order :created_at }
  has_many :infections
  has_many :active_infections, -> { order :created_at }
  has_many :bookmarks, -> { order :created_at }

  def self.password_attributes
    [:password, :password_digest, :resetting_password]
  end

  def self.private_attributes
    password_attributes + [:notifications_enabled, :access_token]
  end

  def authenticate(password)
    ::BCrypt::Password.new(password_digest) == password
  end

  def password=(new_password)
    @password = new_password
    self.password_digest = ::BCrypt::Password.create(@password)
  end
end
