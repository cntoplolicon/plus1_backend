class CreateEventPages < ActiveRecord::Migration
  def change
    create_table :event_pages do |t|
      t.references :event, null: false, index: true, foreign_key: true
      t.integer :order, null: false
      t.string :image
      t.timestamps null: false
    end
  end
end
