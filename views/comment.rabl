object @comment

attributes :id, :post_id, :reply_to_id, :content, :created_at
node :user do |comment|
  partial('user', object: comment.user)
end
