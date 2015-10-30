attributes :id, :username, :nickname, :gender, :biography, :created_at
node :avatar do |user|
  image_url(user.avatar)
end
