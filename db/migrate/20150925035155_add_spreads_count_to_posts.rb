class AddSpreadsCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :spreads_count, :integer, null: false, default: 0
  end
end
