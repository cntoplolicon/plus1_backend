def send_sms_message(mobile, msg)
  uri = URI('http://222.73.117.158/msg/HttpBatchSendSM')
  params = {account: settings.sms[:username], pswd: settings.sms[:password], mobile: mobile, msg: msg}
  uri.query = URI.encode_www_form(params)
  if Sinatra::Base.development?
    p "sms message: #{msg}"
  else
    Net::HTTP.get(uri)
  end
end

def generate_security_code
  (1..6).map { rand(10) }.join
end

def send_security_code(username)
  security_code = generate_security_code
  send_sms_message(username, settings.security_code[:template] % {security_code: security_code})
  user_security_code = UserSecurityCode.where(username: username).first_or_initialize
  user_security_code.update_attributes(username: username, security_code: security_code, verified: false)
  user_security_code.save(validate: false)
end

def confirm_username_verified(username)
  user_security_code = UserSecurityCode.find_by_username!(username)
  unless user_security_code.verified
    user_security_code.errors.add(:username, 'not verified')
    halt 400, json(errors: user_security_code.errors)
  end
  user_security_code
end

def generate_access_token
  SecureRandom.hex
end

def validate_access_token
  user_id = params[:user_id]
  return unless user_id =~ /\A\d+\Z/
  @user = User.find(user_id)
  halt 403 if params[:access_token] != @user.access_token
end

post '/users' do
  user = User.new(can_infect: 4, access_token: generate_access_token)
  user.save(validate: false)

  content_type :json
  return 201, user.to_json(only: [:id, :access_token])
end

post '/security_codes/account' do
  username = params[:username]
  halt 400 unless username

  user = User.find_by_username(username)
  if user
    user.errors.add(:username, 'duplicated')
    halt 409, json(errors: user.errors)
  end

  send_security_code(username)
  json(status: 'success')
end

post '/security_codes/password' do
  username = params[:username]
  halt 400 unless username
  user = User.find_by_username(username)

  unless user
    user = User.new
    user.errors.add(:username, 'unknown')
    halt 400, json(errors: user.errors)
  end

  send_security_code(username)
  json(status: 'success')
end

post '/security_codes/verify' do
  username = params[:username]
  security_code = params[:security_code]
  halt 400 unless security_code && username
  user_security_code = UserSecurityCode.find_by_username(username)
  if !user_security_code
    user_security_code = UserSecurityCode.new
    user_security_code.errors.add(:username, 'security code not sent')
  elsif user_security_code.updated_at + settings.security_code[:expire].second < Time.zone.now
    user_security_code.errors.add(:security_code, 'expired')
  elsif user_security_code.security_code != security_code
    user_security_code.errors.add(:security_code, 'incorrect')
  end
  halt 400, json(errors: user_security_code.errors) if user_security_code.errors.any?
  user_security_code.update(verified: true)
  json(status: 'success')
end

put '/users/password' do
  user = User.find_by_username!(params[:username])
  user_security_code = confirm_username_verified(user.username)
  user.resetting_password = true
  user.password = params[:password]
  halt 400, json(errors: user.errors) unless user.save
  user_security_code.destroy
  json(status: 'success')
end

put '/users/:user_id' do
  user = User.find(params[:user_id])
  temp_user = !user.username
  user.resetting_password = temp_user || params[:password]
  user_params = params.deep_symbolize_keys.slice(:username, :password, :nickname, :gender)

  username = params[:username]
  if username && User.where(username: username).count > 0
    user.errors.add(:username, 'duplicated')
    halt 400, json(errors: user.errors)
  end

  user_security_code = confirm_username_verified(username) if username
  password = params[:password]
  if password && !temp_user
    old_password = params[:old_password]
    unless user.authenticate(old_password)
      user.errors.add(:old_password, 'incorrect')
      halt 400, json(errors: user.errors)
    end
  end

  user.attributes = user_params
  user.avatar = upload_file_to_s3(params[:avatar]) if params[:avatar]
  halt 400, json(errors: user.errors) unless user.save
  user_security_code.destroy if user_security_code

  content_type :json
  user.to_json(except: [:password, :password_digest, :resetting_password])
end

post '/signIn' do
  username = params[:username]
  password = params[:password]
  halt 400 unless username && password

  user = User.find_by_username(username)
  unless user
    user = User.new
    user.errors.add(:username, 'unknown')
    halt 400, json(errors: user.errors)
  end
  unless user.authenticate(password)
    user.errors.add(:password, 'incorrect')
    halt 400, json(errors: user.errors)
  end

  user.update(access_token: generate_access_token)
  content_type :json
  user.to_json(except: [:password, :password_digest, :resetting_password])
end

get '/users/:user_id' do
  validate_access_token
  content_type :json
  @user.to_json(except: [:password_digest, :password, :resetting_password,
                         :access_token])
end
