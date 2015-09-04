class CreateInfections < ActiveRecord::Migration
  def change
    create_table :infections do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.references :post, null: false, index: true, foreign_key: true
      t.references :post_view, index: true
    end
  end
end
