class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.references :post, null: false, index: true, foreign_key: true
      t.timestamps null: false
    end
    add_index :bookmarks, [:user_id, :post_id], unique: true
  end
end
