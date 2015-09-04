class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :post, null: false, index: true, foreign_key: true
      t.references :user, null: false, index: true, foreign_key: true
    end
  end
end
