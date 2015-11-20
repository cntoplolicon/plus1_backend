object @post

attributes :id, :spreads_count, :views_count, :comments_count, :bookmarked, :recommendation, :deleted_by, :created_at
child :post_pages do
  attributes :id, :text, :image_width, :image_height
  node :image do |post|
    image_url(post.image)
  end
end
child :user do
  extends 'user'
end
