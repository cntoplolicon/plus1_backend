class AddOauthIdsToAccountInfos < ActiveRecord::Migration
  def change
    add_column :account_infos, :weixin_union_id, :string
    add_column :account_infos, :qq_uid, :string
    add_column :account_infos, :sina_weibo_uid, :string
  end
end
