class RenameUserInfoToUserinfo < ActiveRecord::Migration
  def self.up
    rename_table :user_infos, :userinfos
  end

  def self.down
    rename_table :userinfos, :user_infos
  end
end
