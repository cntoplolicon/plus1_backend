require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'net/http'
require './settings'

require 'byebug' if Sinatra::Base.development?

Dir['./models/*.rb'].each do |f|
  require f
end
Dir['./controllers/*.rb'].each do |f|
  require f
end

Time.zone_default = Time.find_zone('Beijing')
