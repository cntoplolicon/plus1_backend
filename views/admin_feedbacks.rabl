collection @feedbacks

attributes :id, :contact, :content, :created_at
child :user do
  extends 'user'
end
