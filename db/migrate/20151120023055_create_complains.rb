class CreateComplains < ActiveRecord::Migration
  def change
    create_table :complains do |t|
      t.references :post, null: false, index: true, foreign_key: true
      t.references :user, null: false, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
