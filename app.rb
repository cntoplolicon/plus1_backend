require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'sinatra/config_file'
require 'net/http'
require 'rabl'
require 'byebug' if Sinatra::Base.development?
require './helpers'

set :environments, %w(development test production staging)

config_file './config.yml'

Dir['./models/*.rb'].each do |f|
  require f
end
Dir['./controllers/*.rb'].each do |f|
  require f
end

Time.zone_default = Time.find_zone('Beijing')
Rabl.register!
set :rabl, format: :json
Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root = false
end

def success
  json(status: 'success')
end

def rabl_json(template, options = {})
  content_type :json
  rabl(template, options)
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/app_release/android' do
  @app_release = AppRelease.first
  if @app_release
    json @app_release
  else
    json version_code: 0
  end
end
