class AddReceiverSenderDeleteToChat < ActiveRecord::Migration
  def change
    add_column :chats, :receiver_delete, :boolean, :default => false
    add_column :chats, :sender_delete, :boolean, :default => false
  end
end
