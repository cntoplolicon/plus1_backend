class RemoveLikes < ActiveRecord::Migration
  def change
    drop_table :likes
    remove_column :posts, :likes_count
  end
end
