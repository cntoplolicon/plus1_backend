require 'rmagick'
require 'ruby_apk'
require 'nokogiri'

def validate_admin_account
  @user = User.where(username: params[:username]).take
  halt 403 unless @user && @user.admin? && @user.authenticate(params[:password])
end

def update_event_attributes
  Event.transaction do
    event_params = params.deep_symbolize_keys.slice(:description)
    @event.attributes = event_params
    if params[:image_files]
      @event.event_pages.destroy_all
      params[:image_files].each_with_index do |image_file, i|
        image_path = compress_and_upload_image(image_file[:tempfile])
        @event.event_pages.build(image: image_path, order: i)
      end
    end
    halt 400, json(@event.errors) unless @event.save
  end
end

def compress_and_upload_image(temp_file)
  image = Magick::Image.read(temp_file.path).first
  image = image.resize_to_fit(960, 960)
  tempfile = Tempfile.new('image')
  begin
    image.write(tempfile.path) do
      self.format = 'JPEG'
      self.quality = 75
    end
    return upload_file_to_s3(filename: 'image.jpg', type: 'image/jpeg', tempfile: tempfile)
  ensure
    tempfile.close
    tempfile.unlink
  end
end

before '/admin/*' do
  return unless Sinatra::Base.production?
  @auth ||= Rack::Auth::Basic::Request.new(request.env)
  authenticated = @auth.provided? && @auth.basic? && @auth.credentials &&
    @auth.credentials == [settings.admin[:username], settings.admin[:password]]
  return if authenticated
  headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
  halt 401, "Not authorized\n"
end

get '/admin/users' do
  @users = User.all
  search = params[:search]
  @users = @users.where('username like ? or nickname like ?', "%#{search}%", "%#{search}%").limit(100) if search

  rabl_json :admin_users
end

get '/admin/users/:user_id' do
  @user = User.where(id: params[:user_id]).includes(posts: :post_pages).take
  rabl_json :admin_user
end

get '/admin/feedbacks' do
  @feedbacks = Feedback.includes(:user).joins(:user).order(created_at: :desc)
  username = params[:username]
  @feedbacks = @feedbacks.where(users: {username: username}) if username
  @feedbacks = @feedbacks.limit(1000) unless username

  rabl_json :admin_feedbacks
end

get '/admin/complains' do
  @complains = Complain.includes(:user).joins(:user).order(created_at: :desc)
  username = params[:username]
  @complains = @complains.where(users: {username: username}) if username
  @complains = @complains.limit(1000) unless username

  rabl_json :admin_complains
end

get '/admin/posts/:post_id' do
  @post = Post.where(id: params[:post_id]).joins(:post_pages).includes({comments: :user}, :post_pages).take
  rabl_json :post_with_comments
end

post '/admin/posts/:post_id/deleted_by' do
  @post = Post.find(params[:post_id])
  if @post.deleted_by == Post::DELETED_BY_AUTHOR
    @post.errors.add(:post_id, 'deleted by author')
    halt 400, json(@posts.errors)
  end
  @post.update(deleted_by: params[:deleted_by])
  rabl_json :post_with_comments
end

post '/admin/posts/:post_id/comments' do
  validate_admin_account
  reply_to = Comment.find(params[:reply_to]) if params[:reply_to]
  content = params[:content]
  halt 400 unless content

  Post.transaction do
    post = Post.find(params[:post_id])
    comment_params = {user_id: @user.id, content: content}
    comment_params[:reply_to_id] = reply_to.id if reply_to
    post.comments.create(comment_params)
    Post.where(id: post.id).update_all('comments_count = comments_count + 1')
  end

  @post = Post.where(id: params[:post_id]).joins(:post_pages).includes({comments: :user}, :post_pages).take
  rabl_json :post_with_comments
end

put '/admin/posts/:post_id/recommendation' do
  @post = Post.where(id: params[:post_id]).joins(:post_pages).includes({comments: :user}, :post_pages).take
  original_recommended = @post.recommended?
  @post.update(params.deep_symbolize_keys.slice(:recommendation))
  if !original_recommended && @post.recommended?
    user = @post.user
    post_json = render :rabl, :post
    notification_content = build_notification_content(user.id, 'recommend', post_json)
    publish_notification(user.account_info.av_installation_id, notification_content)
  end
  rabl_json :post_with_comments
end

post '/admin/users/:user_id/posts' do
  validate_admin_account

  post = @user.posts.build
  params[:post_pages].each_with_index do |post_page, i|
    post_page = post_page.deep_symbolize_keys
    halt 400 if !post_page[:text] && !post_page[:image]
    page_params = post_page.slice(:text).merge(order: i)
    if post_page[:image]
      image_path = compress_and_upload_image(post_page[:image][:tempfile])
      page_params = page_params.merge(image_width: image.columns, image_height: image.rows, image: image_path)
    end
    post.post_pages.build(page_params)
  end

  ActiveRecord::Base.transaction do
    halt 400, json(errors: post.errors) unless post.save

    new_user_ids = User.where.not(id: @user.id)
      .order('RAND()').limit(@user.can_infect).pluck(:id)
    new_infections_params = new_user_ids.map do |user_id|
      {user_id: user_id, post_id: post.id, active: true}
    end
    Infection.create(new_infections_params)
  end

  @user = User.where(id: params[:user_id]).includes(posts: :post_pages).take
  rabl_json :admin_user
end

get '/admin/app_release/android' do
  @app_release = AppRelease.first
  if @app_release
    json @app_release
  else
    json version_code: 0
  end
end

post '/admin/app_release/android' do
  @app_release = AppRelease.first_or_initialize
  @app_release.message = params[:message]

  if params[:archive]
    apk = Android::Apk.new(params[:archive][:tempfile].path)
    manifest = apk.manifest
    xml = Nokogiri::XML(manifest.to_xml)
    version_code = xml.root['android:versionCode'].to_i
    version_name = xml.root['android:versionName']
    @app_release.version_code = version_code
    @app_release.version_name = version_name

    path = upload_file_to_s3(params[:archive], key: params[:archive][:filename], bucket: settings.s3[:storage_bucket])
    @app_release.download_url = settings.cdn[:storage_host] + path
  end

  @app_release.save
  json @app_release
end

post '/admin/events' do
  @event = Event.new
  update_event_attributes
  rabl_json :event
end

put '/admin/events/:event_id' do
  @event = Event.find(params[:event_id])
  update_event_attributes
  rabl_json :event
end

get '/admin/events' do
  @events = Event.all
  rabl_json :events
end

get '/admin/events/:event_id' do
  @event = Event.find(params[:event_id])
  rabl_json :event
end
