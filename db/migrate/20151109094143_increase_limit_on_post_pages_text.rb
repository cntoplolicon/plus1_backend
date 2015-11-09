class IncreaseLimitOnPostPagesText < ActiveRecord::Migration
  def change
    change_column :post_pages, :text, :string, limit: 4096
  end
end
