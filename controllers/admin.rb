get '/admin/users' do
  users = User.all
  search = params[:search]
  users = users.where('username like ? or nickname like ?', "%#{search}%", "%#{search}%").limit(100) if search
  users.to_json(except: User.private_attributes)
end

get '/admin/users/:user_id' do
  user = User.where(id: params[:user_id]).includes(posts: :post_pages)
  user.to_json(except: User.private_attributes, include: {posts: {include: :post_pages}})
end
