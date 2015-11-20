class AddDeletedByToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :deleted_by, :integer
  end
end
