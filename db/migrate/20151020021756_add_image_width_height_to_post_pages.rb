class AddImageWidthHeightToPostPages < ActiveRecord::Migration
  def change
    add_column :post_pages, :image_width, :integer
    add_column :post_pages, :image_height, :integer
  end
end
