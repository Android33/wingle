class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|

      t.string  :chat_msg
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
  end
end
