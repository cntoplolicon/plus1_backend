class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, index: true
      t.string :nickname, index: true
      t.string :password_digest
      t.string :avatar
      t.string :biography
      t.integer :gender
      t.integer :can_infect
      t.integer :infection_index
    end
  end
end
