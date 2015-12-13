class CreateChatsUsersJoinTable < ActiveRecord::Migration
  def self.up
    create_table :chats_users, :id => false do |t|
      t.integer :chat_id
      t.integer :user_id
    end

    add_index :chats_users, [:chat_id, :user_id]
  end

  def self.down
    drop_table :chats_users
  end
end
