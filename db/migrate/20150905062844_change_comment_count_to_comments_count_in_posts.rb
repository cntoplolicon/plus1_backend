class ChangeCommentCountToCommentsCountInPosts < ActiveRecord::Migration
  def change
    rename_column :posts, :comment_count, :comments_count
  end
end
