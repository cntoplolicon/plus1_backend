class RemoveRecommendedFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :recommended
  end
end
