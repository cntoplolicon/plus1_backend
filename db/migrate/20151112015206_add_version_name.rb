class AddVersionName < ActiveRecord::Migration
  def change
    add_column :app_releases, :version_name, :string
  end
end
