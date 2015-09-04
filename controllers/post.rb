post '/users/:user_id/posts' do
  post = @user.posts.build
  params[:post_pages].each_with_index do |post_page, i|
    post_page = post_page.deep_symbolize_keys
    image = upload_file_to_s3(post_page[:image]) if post_page[:image]
    page_params = post_page.slice(:text).merge(order: i, image: image)
    post.post_pages.build(page_params)
  end
  halt 400, json(errors: post.errors) unless post.save
  200
end

get '/users/:user_id/posts' do
  posts = Post.where(user_id: @user.id).joins(:post_pages).includes(:post_pages)
  content_type :json
  posts.to_json(except: :updated_at, include: {post_pages: {except: [:post_id, :created_at, :updated_at]}})
end
