class ChangeGenderToNotNullInUsers < ActiveRecord::Migration
  def change
    change_column_null :users, :gender, false
    change_column_default :users, :gender, 0
  end
end
