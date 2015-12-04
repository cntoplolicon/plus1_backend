require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/json'
require 'sinatra/config_file'
require 'net/http'
require 'rabl'
require 'byebug' if Sinatra::Base.development?

set :environments, %w(development test production staging)

config_file './config.yml'

Dir['./models/*.rb'].each do |f|
  require f
end
Dir['./controllers/*.rb'].each do |f|
  require f
end

Time.zone_default = Time.find_zone('Beijing')
Rabl.register!
set :rabl, format: :json
Rabl.configure do |config|
  config.include_json_root = false
  config.include_child_root = false
end

def success
  json(status: 'success')
end

def rabl_json(template, options = {})
  content_type :json
  rabl(template, options)
end

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

get '/app_release/android' do
  @app_release = AppRelease.first
  if @app_release
    json @app_release
  else
    json version_code: 0
  end
end

def dfs(map, comment)
  @comments_sorted.push(comment)
  map[comment.id].each do |reply_comment|
    dfs(map, reply_comment)
  end
end

def get_reply_comment(comment_id)
  @comments_sorted.find{|comment| comment.id == comment_id}
end

helpers do
  def image_url(path)
    return nil unless path
    return path if path.start_with?('http')
    settings.cdn[:hosts].sample + path
  end

  def name_span(user)
    case user.gender
    when 1
      gender_color = '#5a96f0'
    when 2
      gender_color = '#ff62b8'
    else
      gender_color = '#cccccc'
    end
    %Q[<span style="color: #{gender_color}">#{user.nickname}</span>]
  end

  def gender_icon(gender)
    case gender
    when 1
      %Q[<img class="user_icon" src='../images/icon_man.png'>]
    when 2
      %Q[<img class="user_icon" src='../images/icon_woman.png'>]
    end
  end

  def time_ago(date)
    time_ago = Time.now - date
    return (time_ago/1.days).to_i.to_s + '天前' if (time_ago/1.days).to_i > 0
    return (time_ago/1.hours).to_i.to_s + '小时前' if (time_ago/1.hours).to_i > 0
    return (time_ago/1.minutes).to_i.to_s + '分钟前' if (time_ago/1.minutes).to_i > 0
    return '刚刚'
  end

  def user_avatar(user)
    source = user.avatar ? image_url(user.avatar) : '../images/default_user_avatar.png'
    %Q[<img class="image-avatar" src= #{source} >]
  end

  def sort_comment(comments)
    @comments_sorted = Array.new()
    comments.sort_by {|comment| [comment.created_at, comment.id]}
    comments_map = Hash[comments.map{|comment| [comment.id, Array.new()]}]
    comments.each do |comment|
      comments_map[comment.reply_to_id].push(comment) if comment.reply_to_id
    end
    comments.each do |comment|
      dfs(comments_map, comment) if !comment.reply_to_id
    end
    @comments_sorted
  end

end
