class AddLogoWidthAndHeightToEvent < ActiveRecord::Migration
  def change
    add_column :events, :logo_width, :integer
    add_column :events, :logo_height, :integer
  end
end
