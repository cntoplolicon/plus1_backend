class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :user
      t.string :contact, null: false
      t.string :content, null: false
      t.timestamps null: false
    end
  end
end
