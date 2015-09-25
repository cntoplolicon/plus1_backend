class AddViewsCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :views_count, :integer, null: false, default: 0
  end
end
