post '/posts/:post_id/likes' do
  validate_access_token

  post = Post.find(params[:post_id])
  Post.transaction do
    like_params = {user_id: @user.id}
    post.likes.create(like_params)
    Post.where(id: post.id).update_all('likes_count = likes_count + 1')
  end
  200
end
