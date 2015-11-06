class CreateAccountInfos < ActiveRecord::Migration
  def change
    create_table :account_infos do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :av_installation_id
      t.timestamps null: false
    end
  end
end
