def set_bookmarked(posts, user)
  bookmarked_post_ids = Set.new(Bookmark.where(user_id: user.id).pluck(:post_id))
  posts.each do |post|
    post.bookmarked = bookmarked_post_ids.include?(post.id)
  end
end

post '/users/:user_id/posts' do
  validate_access_token

  post = @user.posts.build
  params[:post_pages].each_with_index do |post_page, i|
    post_page = post_page.deep_symbolize_keys
    image = upload_file_to_s3(post_page[:image]) if post_page[:image]

    page_params = post_page.slice(:text, :image_width, :image_height).merge(order: i, image: image)
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

  status 201
  @post = post
  rabl_json :post
end

delete '/users/:user_id/posts/:post_id' do
  validate_access_token

  @post = @user.posts.find(params[:post_id])
  @post.update(deleted_by: Post::DELETED_BY_AUTHOR) if @post.deleted_by != Post::DELETED_BY_ADMIN
  @post.bookmarked = Bookmark.where(user_id: @user.id, post_id: @post.id).exists?
  rabl_json :post
end

get '/users/:author_id/posts' do
  validate_access_token
  @posts = Post.where(user_id: params[:author_id], deleted_by: nil).joins(:post_pages, :user)
    .includes(:post_pages, :user).order(created_at: :desc)
  set_bookmarked(@posts, @user)
  rabl_json :posts
end

post '/users/:user_id/infections/:infection_id/post_view' do
  validate_access_token

  ActiveRecord::Base.transaction do
    infection = @user.infections.find(params[:infection_id])
    halt 409 unless infection.active

    result = params[:result].to_i
    halt 400 unless [PostView::SPREAD, PostView::SKIP].include?(result)

    post = Post.find(infection.post_id)
    result = PostView::POST_DELETED if post.deleted?

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

    @post_view = post_view
  end

  rabl_json :post_view
end

get '/users/:user_id/infections/active' do
  validate_access_token

  @infections = Infection.where(user_id: @user.id, active: true)
    .joins(post: :user).includes(post: [:user, :post_pages]).order('posts.created_at desc').limit(100)
  bookmarked_post_ids = Set.new(Bookmark.where(user_id: @user.id).pluck(:post_id))

  @infections.each do |infection|
    infection.post.bookmarked = bookmarked_post_ids.include?(infection.post.id)
  end

  rabl_json :infections
end

post '/posts/:post_id/comments' do
  validate_access_token
  post = Post.find(params[:post_id])
  reply_to = post.comments.find(params[:reply_to]) if params[:reply_to]
  content = params[:content]
  halt 400 unless content

  Post.transaction do
    comment_params = {user_id: @user.id, content: content}
    comment_params[:reply_to_id] = reply_to.id if reply_to
    comment = post.comments.create(comment_params)
    Post.where(id: post.id).update_all('comments_count = comments_count + 1')

    bookmark_params = {user_id: @user.id, post_id: post.id}
    Bookmark.where(bookmark_params).first_or_initialize(bookmark_params).save
    comment.post.bookmarked = true

    replied_user = reply_to ? reply_to.user : post.user
    replied_comment_deleted = reply_to && reply_to.deleted
    @comment = comment
    comment_json = render :rabl, :comment_with_post
    if replied_user.id != @user.id && replied_user.account_info && !post.deleted? &&
        replied_user.account_info.av_installation_id && !replied_comment_deleted
      notification_content = build_notification_content(replied_user.id, 'comment', comment_json)
      publish_notification(replied_user.account_info.av_installation_id, notification_content)
    end
  end

  status 201
  rabl_json :comment_with_post
end

delete '/posts/:post_id/comments/:comment_id' do
  validate_access_token
  @comment = Comment.find(params[:comment_id])
  halt 400 unless @comment.post_id == params[:post_id].to_i
  @comment.update(deleted: true)
  rabl_json :comment
end

post '/users/:user_id/bookmarks' do
  validate_access_token

  halt 400 unless params[:post_id]
  post_id = params[:post_id].to_i

  bookmark_params = {user_id: @user.id, post_id: post_id}
  bookmark = Bookmark.where(bookmark_params).first_or_initialize(bookmark_params)
  bookmark.save

  @post = bookmark.post
  @post.bookmarked = true
  status 201
  rabl_json :post
end

delete '/users/:user_id/bookmarks/:post_id' do
  validate_access_token
  post_id = params[:post_id].to_i
  Bookmark.where(user_id: @user.id, post_id: post_id).destroy_all

  @post = Post.find(post_id)
  @post.bookmarked = false
  rabl_json :post
end

get '/users/:user_id/bookmarks' do
  validate_access_token
  @posts = Post.joins(:bookmarks, :post_pages, :user).includes(:bookmarks, :post_pages, :user)
    .where(deleted_by: nil, bookmarks: {user_id: @user.id}).order('bookmarks.created_at desc')
  @posts.each do |post|
    post.bookmarked = true
  end
  rabl_json :posts
end

get '/posts/:post_id.?:format?' do
  @post = Post.where(id: params[:post_id]).joins(:post_pages).includes({comments: :user}, :post_pages).take
  return erb :share_post if params[:format] == 'html'
  validate_access_token
  @post.bookmarked = Bookmark.where(user_id: @user.id, post_id: @post.id).exists?
  rabl_json :post_with_comments
end

get '/recommendations' do
  validate_access_token
  @posts = Post.where(deleted_by: nil).where.not(recommendation: nil)
    .joins(:user, :post_pages).includes(:user, :post_pages).order(recommendation: :desc, created_at: :desc)
  set_bookmarked(@posts, @user)
  rabl_json :posts
end

get '/events/:event_id/recommendations' do
  validate_access_token
  @posts = Post.where(deleted_by: nil, event_id: params[:event_id]).where.not(recommendation: nil)
    .joins(:user, :post_pages).includes(:user, :post_pages).order(recommendation: :desc, created_at: :desc)
  set_bookmarked(@posts, @user)
  rabl_json :posts
end

post '/users/:user_id/complains' do
  validate_access_token

  halt 400 unless params[:post_id]
  post_id = params[:post_id].to_i

  complain_params = {post_id: post_id, user_id: @user.id}
  halt 409 if Complain.where(complain_params).exists?

  complain = Complain.create(complain_params)
  status 201
  json complain
end

def comments_dfs(map, comment)
  @comments_sorted.push(comment)
  map[comment.id].each do |reply_comment|
    comments_dfs(map, reply_comment)
  end
end

helpers do
  def image_url(path)
    return nil unless path
    return path if path.start_with?('http')
    settings.cdn[:hosts].sample + path
  end

  def user_avatar(user)
    source = user.avatar ? image_url(user.avatar) : '../images/default_user_avatar.png'
    %Q[<img class="image-avatar" src= #{source} >]
  end

  def name_span(user)
    case user.gender
    when User::GENDER_MALE
      gender_color = '#5a96f0'
    when User::GENDER_FEMALE
      gender_color = '#ff62b8'
    else
      gender_color = '#cccccc'
    end
    %Q[<span style="color: #{gender_color}">#{user.nickname}</span>]
  end

  def gender_icon(gender)
    case gender
    when User::GENDER_MALE
      %Q[<img class="user_icon" src='../images/icon_man.png'>]
    when User::GENDER_FEMALE
      %Q[<img class="user_icon" src='../images/icon_woman.png'>]
    end
  end

  def time_ago(date)
    time_ago = Time.now - date
    days_ago = (time_ago / 1.days).to_i
    hours_ago = (time_ago/1.hours).to_i
    minutes_ago = (time_ago/1.minutes).to_i
    case
    when days_ago > 0
      "#{days_ago}天前"
    when hours_ago > 0
      "#{hours_ago}小时前"
    when minutes_ago > 0
      "#{minutes_ago}分钟前"
    else
      "刚刚"
    end
  end

  def comments_list(comments)
    @comments_sorted = Array.new()
    comments.sort_by {|comment| [comment.created_at, comment.id]}
    comments_map = Hash[comments.map{|comment| [comment.id, Array.new()]}]
    comments.each do |comment|
      comments_map[comment.reply_to_id].push(comment) if comment.reply_to_id
    end
    comments.each do |comment|
      comments_dfs(comments_map, comment) unless comment.reply_to_id
    end

    %Q[<div class="commnet-container">
      #{@comments_sorted.map do |comment|
        %Q[#{unless comment.reply_to_id
          %Q[<div>
               #{user_avatar(comment.user)}
               <div class="comment-detail">
                 #{name_span(comment.user)}
                 <p class="comment-content">#{comment.content}</p>
               </div>
             </div>]
         else
          %Q[<div class="reply-comment">
               #{user_avatar(comment.user)}
               <div class="comment-detail">
                 #{name_span(comment.user)}
                 <span>回复</span>
                 #{name_span(@comments_sorted.find{|target| target.id == comment.reply_to_id}.user)}
                 <p class="comment-content">#{comment.content}</p>
               </div>
             </div>]
         end}]
       end.join}
       </div>]
  end
end