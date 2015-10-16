class RemoveNotificationsEnabledFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :notifications_enabled
  end
end
