class AddTimestampsToComments < ActiveRecord::Migration
  def change
    add_timestamps :comments, null: false
  end
end
