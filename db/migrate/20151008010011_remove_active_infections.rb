class RemoveActiveInfections < ActiveRecord::Migration
  def change
    drop_table :active_infections
  end
end
