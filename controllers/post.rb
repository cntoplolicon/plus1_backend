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
      {user_id: user_id, post_id: post.id}
    end
    new_infections = Infection.create(new_infections_params)

    new_active_infections_params = new_infections.map do |new_infection|
      {user_id: new_infection.user_id, infection_id: new_infection.id}
    end
    ActiveInfection.create(new_active_infections_params)
  end

  json(status: 'success')
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
    halt 409 if infection.post_view

    active_infection = infection.active_infection
    halt 409 unless active_infection

    result = params[:result].to_i
    halt 400 unless [PostView::SPREAD, PostView::SKIP].include?(result)

    active_infection.destroy
    post_view = infection.create_post_view(user_id: @user.id, post_id: infection.post_id, result: result)
    Post.where(id: infection.post_id).update_all('views_count = views_count + 1')

    if post_view.result == PostView::SPREAD
      infected_user_ids = Infection.select(:user_id).where(post_id: post_view.post_id)
      new_user_ids = User.where.not(id: infected_user_ids).where.not(id: post_view.post.user_id)
        .order('RAND()').limit(@user.can_infect).pluck(:id)

      new_infections_params = new_user_ids.map do |new_user_id|
        {user_id: new_user_id, post_id: post_view.post_id, post_view_id: post_view.id}
      end
      new_infections = Infection.create(new_infections_params)

      new_active_infections_params = new_infections.map do |new_infection|
        {user_id: new_infection.user_id, infection_id: new_infection.id}
      end
      ActiveInfection.create(new_active_infections_params)

      Post.where(id: infection.post_id).update_all('spreads_count = spreads_count + 1')
    end
  end

  json(status: 'success')
end

get '/users/:user_id/infections/active' do
  validate_access_token
  infections = Infection.joins(:active_infection).includes(:active_infection)
    .where(active_infections: {user_id: @user.id})
    .joins(post: :user).includes(post: [:user, :post_pages]).order(:id).limit(100)

  content_type :json
  confidential_user_attributes = [:password, :password_digest, :resetting_password, :access_token]
  infections.to_json(include: {post: {include: {user: {except: confidential_user_attributes}, post_pages: {}}}})
end
