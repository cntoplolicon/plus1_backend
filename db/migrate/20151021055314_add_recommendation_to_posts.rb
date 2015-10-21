class AddRecommendationToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :recommendation, :integer
  end
end
