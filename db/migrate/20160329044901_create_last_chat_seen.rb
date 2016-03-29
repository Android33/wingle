class CreateLastChatSeen < ActiveRecord::Migration
  def change
    create_table :lastchatseens do |t|
      t.integer :user_id

      t.integer :sender_id
      t.integer :chat_id

      t.timestamps
    end
    add_index :lastchatseens, :user_id
  end
end
