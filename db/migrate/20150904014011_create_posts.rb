class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.integer :likes_no, null: false, default: 0
      t.integer :comment_count, null: false, default: 0
      t.timestamps null: false
    end
  end
end
