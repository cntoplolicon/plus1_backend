object @comment

attributes :id, :post_id, :reply_to_id, :created_at
attribute :content, if: ->(comment) { !comment.deleted }

child :user do
  extends 'user'
end
