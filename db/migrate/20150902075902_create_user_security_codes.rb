class CreateUserSecurityCodes < ActiveRecord::Migration
  def change
    create_table :user_security_codes do |t|
      t.string :username, limit: 48
      t.string :security_code
      t.timestamps null: false
    end
    add_index :user_security_codes, :username, unique: true
  end
end
