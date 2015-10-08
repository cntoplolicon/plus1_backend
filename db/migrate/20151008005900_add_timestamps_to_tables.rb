class AddTimestampsToTables < ActiveRecord::Migration
  def change
    add_timestamps :post_pages, null: false
    add_timestamps :post_views, null: false
    add_timestamps :infections, null: false
  end
end
