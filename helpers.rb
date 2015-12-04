def comments_dfs(map, comment)
  @comments_sorted.push(comment)
  map[comment.id].each do |reply_comment|
    comments_dfs(map, reply_comment)
  end
end

helpers do
  def image_url(path)
    return nil unless path
    return path if path.start_with?('http')
    settings.cdn[:hosts].sample + path
  end

  def user_avatar(user)
    source = user.avatar ? image_url(user.avatar) : '../images/default_user_avatar.png'
    %Q[<img class="image-avatar" src= #{source} >]
  end

  def name_span(user)
    case user.gender
    when User::GENDER_MALE
      gender_color = '#5a96f0'
    when User::GENDER_FEMALE
      gender_color = '#ff62b8'
    else
      gender_color = '#cccccc'
    end
    %Q[<span style="color: #{gender_color}">#{user.nickname}</span>]
  end

  def gender_icon(gender)
    case gender
    when User::GENDER_MALE
      %Q[<img class="user_icon" src='../images/icon_man.png'>]
    when User::GENDER_FEMALE
      %Q[<img class="user_icon" src='../images/icon_woman.png'>]
    end
  end

  def time_ago(date)
    time_ago = Time.now - date
    days_ago = (time_ago / 1.days).to_i
    hours_ago = (time_ago/1.hours).to_i
    minutes_ago = (time_ago/1.minutes).to_i
    case
    when days_ago > 0
      "#{days_ago}天前"
    when hours_ago > 0
      "#{hours_ago}小时前"
    when minutes_ago > 0
      "#{minutes_ago}分钟前"
    else
      "刚刚"
    end
  end

  def comments_list(comments)
    @comments_sorted = Array.new()
    comments.sort_by {|comment| [comment.created_at, comment.id]}
    comments_map = Hash[comments.map{|comment| [comment.id, Array.new()]}]
    comments.each do |comment|
      comments_map[comment.reply_to_id].push(comment) if comment.reply_to_id
    end
    comments.each do |comment|
      comments_dfs(comments_map, comment) unless comment.reply_to_id
    end

    %Q[<div class="commnet-container">
      #{@comments_sorted.map do |comment|
        %Q[#{unless comment.reply_to_id
          %Q[<div>
               #{user_avatar(comment.user)}
               <div class="comment-detail">
                 #{name_span(comment.user)}
                 <p class="comment-content">#{comment.content}</p>
               </div>
             </div>]
         else
          %Q[<div class="reply-comment">
               #{user_avatar(comment.user)}
               <div class="comment-detail">
                 #{name_span(comment.user)}
                 <span>回复</span>
                 #{name_span(@comments_sorted.find{|target| target.id == comment.reply_to_id}.user)}
                 <p class="comment-content">#{comment.content}</p>
               </div>
             </div>]
         end}]
       end.join}
       </div>]
  end
end