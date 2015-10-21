class AddRecommendedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :recommended, :boolean, null: false, default: false
  end
end
