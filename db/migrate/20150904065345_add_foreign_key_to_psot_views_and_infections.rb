class AddForeignKeyToPsotViewsAndInfections < ActiveRecord::Migration
  def change
    add_foreign_key :infections, :post_views
    add_foreign_key :post_views, :infections
  end
end
