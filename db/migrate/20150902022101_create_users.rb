class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, limit: 48
      t.string :nickname, limit: 48
      t.string :password_digest
      t.string :avatar
      t.string :biography
      t.integer :gender
      t.integer :can_infect, null: false, default: 0
      t.integer :infection_index, null: false, default: 0
      t.timestamps null: false
    end
    add_index :users, :username, unique: true
    add_index :users, :nickname
  end
end
