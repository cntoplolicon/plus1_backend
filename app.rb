require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'net/http'
require './settings'
require './model'

def send_sms_message(mobile, msg)
  uri = URI('http://222.73.117.158/msg/HttpBatchSendSM')
  params = {account: settings.sms[:username], pswd: settings.sms[:password], mobile: mobile, msg: msg}
  uri.query = URI.encode_www_form(params)
  Net::HTTP.get(uri)
end

def generate_security_code
  (1..6).map { rand(10) }.join
end

post '/users' do
  user = User.new(can_infect: 4)
  user.save(validate: false)

  content_type :json
  return 201, user.to_json(only: [:id])
end

post '/security_codes/account' do
  halt 400 unless params[:username]
  user = User.where(username: params[:username]).take
  if user
    user.errors.add(:username, 'already exists')
    halt 400, json(errors: user.errors)
  end
  username = params[:username]

  security_code = generate_security_code
  send_sms_message(username, settings.security_code[:template] % {security_code: security_code})
  user_security_code = UserSecurityCode.where(username: username).first_or_initialize
  user_security_code.update_attributes(username: username, security_code: security_code)
  user_security_code.save(validate: false)
  200
end

put '/users/:user_id' do
  user = User.find(params[:user_id])
  user.resetting_password = !user.username || params[:password]
  user_params = params.deep_symbolize_keys.slice(:username, :password, :nickname, :gender)
  user.attributes = user_params
  username = params[:username]
  user_security_code = nil
  if username
    user_security_code = UserSecurityCode.find_by_username(username)
    security_code_error = nil
    if user_security_code.updated_at + settings.security_code[:expire].second < Time.now
      security_code_error = 'expired'
      user_security_code.destroy
    elsif user_security_code.security_code != params[:security_code]
      security_code_error = 'incorrect'
    end
    if security_code_error
      user.errors.add(:security_code, security_code_error)
      halt 400, json(errors: user.errors)
    end
  end

  p 'tryign to save'
  halt 400, json(errors: user.errors) unless user.save
  user_security_code.destroy if user_security_code
  200
end
