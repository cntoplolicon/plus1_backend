class CreatePostPages < ActiveRecord::Migration
  def change
    create_table :post_pages do |t|
      t.references :post, null: false, index: true, foreign_key: true
      t.integer :order, null: false
      t.string :image
      t.string :text
    end
  end
end
