object @user

attributes :id, :username, :nickname, :gender, :biography, :created_at, :access_token
node :avatar do |user|
  image_url(user.avatar)
end
