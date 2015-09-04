class ChangeLikesNoIntoLikesCountInPosts < ActiveRecord::Migration
  def change
    rename_column :posts, :likes_no, :likes_count
  end
end
