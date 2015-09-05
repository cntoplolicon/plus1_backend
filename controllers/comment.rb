post '/posts/:post_id/comments' do
  validate_access_token
  reply_to = Comment.find(params[:reply_to]) if params[:reply_to]
  content = params[:content]
  halt 400 unless content

  Post.transaction do
    post = Post.find(params[:post_id])
    comment_params = {user_id: @user.id, content: content}
    if reply_to
      comment_params[:reply_to_id] = reply_to.id
      comment_params[:root_comment_id] = reply_to.root_comment_id || reply_to.id
    end
    post.comments.create(comment_params)
    Post.where(id: post.id).update_all('comments_count = comments_count + 1')
  end
  200
end

get '/posts/:post_id/comments/hierachy' do
  validate_access_token
  content_type :json
  user_attributes = [:id, :nickname, :avatar]
  root_comments = Comment.where(post_id: params[:post_id], root_comment_id: nil).includes(:discussions)

  content_type :json
  root_comments.to_json(include:
                        {user: {only: user_attributes},
                         discussions: {include: {user: {only: user_attributes}}}
  })
end
