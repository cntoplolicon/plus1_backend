class AddAccessTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string, limit: 48
  end
end
