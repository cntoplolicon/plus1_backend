collection @complains

attributes :id, :post_id, :created_at
child :user do
  extends 'user'
end
