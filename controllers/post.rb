post '/users/:user_id/posts' do
  validate_access_token

  post = @user.posts.build
  params[:post_pages].each_with_index do |post_page, i|
    post_page = post_page.deep_symbolize_keys
    image = upload_file_to_s3(post_page[:image]) if post_page[:image]

    page_params = post_page.slice(:text).merge(order: i, image: image)
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

  return 201, posts.to_json(except: :updated_at, include: :post_pages)
end

get '/users/:author_id/posts' do
  validate_access_token
  posts = Post.where(user_id: params[:author_id]).joins(:post_pages).includes(:post_pages)
  content_type :json
  posts.to_json(except: :updated_at, include: :post_pages)
end

post '/users/:user_id/infections/:infection_id/post_view' do
  validate_access_token
  ActiveRecord::Base.transaction do
    infection = @user.infections.find(params[:infection_id])
    halt 409 unless infection.active

    result = params[:result].to_i
    halt 400 unless [PostView::SPREAD, PostView::SKIP].include?(result)

    post_view = PostView.create(result: result, infection_id: infection.id)
    Post.where(id: infection.post_id).update_all('views_count = views_count + 1')
    infection.update(active: false)

    if post_view.result == PostView::SPREAD
      infected_user_ids = Infection.select(:user_id).where(post_id: infection.post_id)
      new_user_ids = User.where.not(id: infected_user_ids).where.not(id: infection.post.user_id)
        .order('RAND()').limit(@user.can_infect).pluck(:id)

      new_infections_params = new_user_ids.map do |new_user_id|
        {user_id: new_user_id, post_id: infection.post_id, post_view_id: post_view.id, active: true}
      end
      Infection.create(new_infections_params)

      Post.where(id: infection.post_id).update_all('spreads_count = spreads_count + 1')
    end
  end

  return 201, post_view.to_json
end

get '/users/:user_id/infections/active' do
  validate_access_token
  infections = Infection.where(user_id: @user.id, active: true)
    .joins(post: :user).includes(post: [:user, :post_pages]).order(:id).limit(100)

  content_type :json
  infections.to_json(include: {post: {include: {user: {except: User.private_attributes}, post_pages: {}}}})
end

post '/posts/:post_id/comments' do
  validate_access_token
  reply_to = Comment.find(params[:reply_to]) if params[:reply_to]
  content = params[:content]
  halt 400 unless content

  Post.transaction do
    post = Post.find(params[:post_id])
    comment_params = {user_id: @user.id, content: content}
    comment_params[:reply_to_id] = reply_to.id if reply_to
    comment = post.comments.create(comment_params)
    Post.where(id: post.id).update_all('comments_count = comments_count + 1')

    bookmark_params = {user_id: @user.id, post_id: post.id}
    Bookmark.where(bookmark_params).first_or_initialize(bookmark_params).save

    replied_user = reply_to ? reply_to.user : post.user
    if replied_user.notifications_enabled
      message = comment.to_json(include: {user: {except: User.private_attributes}})
      publish_notification(replied_user.username, build_notification_content('comment', message))
    end
    return 201, comment.to_json
  end
end

get '/posts/:post_id/comments' do
  validate_access_token
  content_type :json
  comments = Comment.where(post_id: params[:post_id]).joins(:user).includes(:user).order(:created_at)

  content_type :json
  comments.to_json(include: {user: {except: User.private_attributes}})
end

post '/users/:user_id/bookmarks' do
  validate_access_token

  halt 400 unless params[:post_id]
  post_id = params[:post_id].to_i

  bookmark_params = {user_id: @user.id, post_id: post_id}
  bookmark = Bookmark.where(bookmark_params).first_or_initialize(bookmark_params)
  bookmark.save

  return 201, bookmark.to_json
end

delete '/users/:user_id/bookmarks/:post_id' do
  validate_access_token
  Bookmark.where(user_id: @user.id, post_id: params[:post_id]).destroy_all
  json(status: 'success')
end

get '/users/:user_id/bookmarks' do
  validate_access_token
  bookmarked_posts = Post.joins(:bookmarks, :post_pages).includes(:bookmarks, :post_pages)
    .where(bookmarks: {user_id: @user.id}).order('bookmarks.created_at')
  bookmarked_posts.to_json(include: :post_pages)
end
