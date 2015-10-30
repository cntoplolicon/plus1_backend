object @comment

attributes :id, :post_id, :reply_to_id, :content, :created_at
child :user do
  extends 'user'
end
