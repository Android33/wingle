class CreateChatimage < ActiveRecord::Migration
  def change
    create_table :chatimages do |t|
      t.string :img
      t.integer :chat_id

      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
    add_index :chatimages, :chat_id
  end
end
