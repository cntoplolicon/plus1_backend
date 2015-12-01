def send_sms_message(mobile, msg)
  uri = URI('http://222.73.117.158/msg/HttpBatchSendSM')
  params = {account: settings.sms[:username], pswd: settings.sms[:password], mobile: mobile, msg: msg}
  uri.query = URI.encode_www_form(params)
  Net::HTTP.get(uri) if Sinatra::Base.production?
  p msg if Sinatra::Base.development?
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
  security_code
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
  @user = User.where(id: params[:user_id]).take
  halt 403 if !@user || params[:access_token] != @user.access_token
end

def update_user_attributes(user)
  user.resetting_password = !user.id || params[:password]

  username = params[:username]
  if username && User.where(username: username).count > 0
    user.errors.add(:username, 'duplicated')
    halt 400, json(errors: user.errors)
  end

  user_security_code = confirm_username_verified(username) if username
  if params[:password] && user.id
    old_password = params[:old_password]
    unless user.authenticate(old_password)
      user.errors.add(:old_password, 'incorrect')
      halt 400, json(errors: user.errors)
    end
  end

  user_params = params.deep_symbolize_keys.slice(:username, :password, :nickname, :gender, :biography)
  user.attributes = user_params
  user.avatar = upload_file_to_s3(params[:avatar]) if params[:avatar]

  User.transaction do
    halt 400, json(errors: user.errors) unless user.save
    user_security_code.destroy if user_security_code
  end
end

def populate_new_user_with_recommendations
  posts_for_new_user_id = Post.where(deleted_by: nil).where.not(recommendation: nil)
    .order(recommendation: :desc).limit(10).pluck(:id)
  new_user_infection_params = posts_for_new_user_id.map do |post_id|
    {user_id: @user.id, post_id: post_id, active: true}
  end
  Infection.create(new_user_infection_params)
end

post '/users' do
  User.transaction do
    @user = User.new(can_infect: 10_000, access_token: generate_access_token)
    update_user_attributes(@user)
    populate_new_user_with_recommendations
  end

  status 201
  rabl :current_user
end

post '/security_codes/account' do
  username = params[:username]
  halt 400 unless username

  user = User.find_by_username(username)
  if user
    user.errors.add(:username, 'duplicated')
    halt 409, json(errors: user.errors)
  end

  security_code = send_security_code(username)
  if Sinatra::Base.production?
    success
  else
    json(security_code: security_code)
  end
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

  security_code = send_security_code(username)
  if Sinatra::Base.production?
    success
  else
    json(security_code: security_code)
  end
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
  success
end

put '/users/password' do
  user = User.find_by_username!(params[:username])
  user_security_code = confirm_username_verified(user.username)
  user.resetting_password = true
  user.password = params[:password]
  halt 400, json(errors: user.errors) unless user.save
  user_security_code.destroy
  success
end

put '/users/:user_id' do
  @user = User.find(params[:user_id])
  update_user_attributes(@user)

  rabl :current_user
end

post '/sign_in' do
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
  @user = user
  rabl :current_user
end

post '/sign_in/oauth' do
  column = {sina: :sina_weibo_uid, qq: :qq_uid, weixin: :weixin_union_id}[params[:platform].to_sym]
  account_info_params = {}
  account_info_params[column] = params[:uid]
  AccountInfo.transaction do
    @user = User.joins(:account_info).includes(:account_info)
      .where(account_infos: account_info_params).first
    if @user
      @user.update(access_token: generate_access_token)
    else
      user_params = params.deep_symbolize_keys.slice(:nickname, :gender, :avatar)
        .merge(can_infect: 10_000, access_token: generate_access_token)
      @user = User.create(user_params)
      populate_new_user_with_recommendations
      @user.create_account_info(account_info_params)
    end
  end
  rabl :current_user
end

post '/users/:user_id/sign_out' do
  validate_access_token
  User.transaction do
    @user.update(access_token: nil)
    @user.account_info.update(av_installation_id: nil) if @user.account_info
  end
  success
end

post '/users/:user_id/account_info' do
  validate_access_token
  account_info = @user.account_info || @user.build_account_info

  account_info_params = params.deep_symbolize_keys.slice(:av_installation_id)
  AccountInfo.transaction do
    account_info.attributes = account_info_params
    if params[:av_installation_id]
      AccountInfo.where(av_installation_id: params[:av_installation_id])
        .where.not(user_id: @user.id)
        .update_all(av_installation_id: nil, updated_at: Time.zone.now)
    end
    account_info.save(validate: false)
  end
  success
end

get '/users/:user_ids' do
  validate_access_token
  user_ids = params[:user_ids]
  @users = User.find(user_ids.split(';'))
  render :rabl, :users
end
