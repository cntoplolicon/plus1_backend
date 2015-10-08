class RemoveUserIdAndPostIdFromPostViews < ActiveRecord::Migration
  def change
    remove_foreign_key :post_views, column: :post_id
    remove_column :post_views, :post_id
    remove_foreign_key :post_views, column: :user_id
    remove_column :post_views, :user_id
  end
end
