class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user

  belongs_to :reply_to, class_name: 'Comment', foreign_key: :reply_to_id, inverse_of: :replies
  has_many :replies, class_name: 'Comment', foreign_key: :reply_to_id, inverse_of: :reply_to

  belongs_to :root_comment, class_name: 'Comment', foreign_key: :root_comment_id, inverse_of: :discussions
  has_many :discussions, class_name: 'Comment', foreign_key: :root_comment_id, inverse_of: :root_comment
end
