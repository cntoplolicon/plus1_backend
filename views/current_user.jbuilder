json.(@user, :id, :username, :nickname, :gender, :biography, :created_at, :access_token)
json.avatar image_url(@user.avatar)
