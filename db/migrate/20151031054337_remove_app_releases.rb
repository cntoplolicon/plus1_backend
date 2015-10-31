class RemoveAppReleases < ActiveRecord::Migration
  def change
    drop_table :app_releases
  end
end
