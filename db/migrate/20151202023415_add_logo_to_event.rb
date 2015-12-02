class AddLogoToEvent < ActiveRecord::Migration
  def change
    add_column :events, :logo, :string
  end
end
