require 'rmagick'

def validate_admin_account
  @user = User.where(username: params[:username]).take
  halt 403 unless @user && @user.authenticate(params[:password])
end

get '/admin/users' do
  users = User.all
  search = params[:search]
  users = users.where('username like ? or nickname like ?', "%#{search}%", "%#{search}%").limit(100) if search

  content_type :json
  users.to_json(except: User.private_attributes)
end

get '/admin/users/:user_id' do
  user = User.where(id: params[:user_id]).includes(posts: :post_pages).take
  content_type :json
  user.to_json(except: User.private_attributes, include: {posts: {include: :post_pages}})
end

get '/admin/feedbacks' do
  feedbacks = Feedback.includes(:user).joins(:user).order(created_at: :desc)
  username = params[:username]
  feedbacks = feedbacks.where(users: {username: username}) if username
  feedbacks = feedbacks.limit(1000) unless username

  content_type :json
  feedbacks.to_json(include: {user: {except: User.private_attributes}})
end

get '/admin/posts/:post_id' do
  post = Post.where(id: params[:post_id]).joins(:post_pages).includes({comments: :user}, :post_pages).take
  content_type :json
  user_json_options = {except: User.private_attributes}
  post.to_json(include: {user: user_json_options, comments: {include: {user: user_json_options}}, post_pages: {}})
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

  post = Post.where(id: params[:post_id]).joins(:post_pages).includes({comments: :user}, :post_pages).take
  content_type :json
  user_json_options = {except: User.private_attributes}
  post.to_json(include: {user: user_json_options, comments: {include: {user: user_json_options}}, post_pages: {}})
end

post '/admin/users/:user_id/posts' do
  validate_admin_account

  post = @user.posts.build
  params[:post_pages].each_with_index do |post_page, i|
    post_page = post_page.deep_symbolize_keys
    halt 400 if !post_page[:text] && !post_page[:image]
    page_params = post_page.slice(:text).merge(order: i)
    if post_page[:image]
      image = Magick::Image.read(post_page[:image][:tempfile].path).first
      image = image.resize_to_fit(960, 960)
      tempfile = Tempfile.new('image')
      begin
        image.write(tempfile.path) do
          self.format = 'JPEG'
          self.quality = 75
        end
        image_path = upload_file_to_s3(filename: 'image.jpg', type: 'image/jpeg', tempfile: tempfile)
        page_params = page_params.merge(image_width: image.columns, image_height: image.rows, image: image_path)
      ensure
        tempfile.close
        tempfile.unlink
      end
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

  user = User.where(id: params[:user_id]).includes(posts: :post_pages).take
  content_type :json
  user.to_json(except: User.private_attributes, include: {posts: {include: :post_pages}})
end
