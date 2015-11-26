class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :events, null: false, index: true, foreign_key: true
      t.integer :order, null: false
      t.string :image
      t.timestamps null: false
    end
  end
end
