object @post

attributes :id, :spreads_count, :views_count, :comments_count
child :post_pages do
  attributes :id, :text, :image, :image_width, :image_height
end
node :user do |post|
  partial('user', object: post.user)
end
