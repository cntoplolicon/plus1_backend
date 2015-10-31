class CreateAppReleases < ActiveRecord::Migration
  def change
    create_table :app_releases do |t|
      t.integer :version_code
      t.text :features
      t.string :download_url
      t.timestamps null: false
    end
    add_index :app_releases, :version_code, unique: true
  end
end
