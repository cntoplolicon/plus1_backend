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
