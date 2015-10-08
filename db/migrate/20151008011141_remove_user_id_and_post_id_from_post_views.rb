class RemoveUserIdAndPostIdFromPostViews < ActiveRecord::Migration
  def change
    remove_foreign_key :post_views, :post_id
    remove_column :post_views, :post_id
    remove_foreign_key :post_views, :user_id
    remove_column :post_views, :user_id
  end
end
