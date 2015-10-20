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
