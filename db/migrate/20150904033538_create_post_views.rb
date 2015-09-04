class CreatePostViews < ActiveRecord::Migration
  def change
    create_table :post_views do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.references :infection, null: false, index: true
      t.references :post, null: false, index: true, foreign_key: true
      t.integer :result
    end
  end
end
