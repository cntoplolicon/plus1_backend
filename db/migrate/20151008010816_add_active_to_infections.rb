class AddActiveToInfections < ActiveRecord::Migration
  def change
    add_column :infections, :active, :boolean, null: false, default: false
  end
end
