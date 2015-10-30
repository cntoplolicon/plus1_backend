require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'sinatra/config_file'
require 'sinatra/jbuilder'
require 'net/http'
require 'byebug' if Sinatra::Base.development?

set :environments, %w(development test production staging)

config_file './config.yml'

Dir['./models/*.rb'].each do |f|
  require f
end
Dir['./controllers/*.rb'].each do |f|
  require f
end

Time.zone_default = Time.find_zone('Beijing')

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/app_info' do
  @app_info = {version_code: 1}
  jbuilder :app_info
end
