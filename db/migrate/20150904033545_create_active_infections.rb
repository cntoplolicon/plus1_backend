class CreateActiveInfections < ActiveRecord::Migration
  def change
    create_table :active_infections do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.references :infection, null: false, index: true, foreign_key: true
    end
  end
end
