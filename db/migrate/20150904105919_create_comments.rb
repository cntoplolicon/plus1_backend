class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :post, null: false, index: true, foreign_key: true
      t.references :user, null: false, index: true, foreign_key: true
      t.integer :reply_to_id
      t.integer :root_comment_id
      t.string :content, null: false
    end
    add_index :comments, :reply_to_id
    add_index :comments, :root_comment_id
    add_foreign_key :comments, :comments, column: :reply_to_id
    add_foreign_key :comments, :comments, column: :root_comment_id
  end
end
