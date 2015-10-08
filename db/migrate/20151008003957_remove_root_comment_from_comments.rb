class RemoveRootCommentFromComments < ActiveRecord::Migration
  def change
    remove_foreign_key :comments, column: :root_comment_id
    remove_column :comments, :root_comment_id
  end
end
