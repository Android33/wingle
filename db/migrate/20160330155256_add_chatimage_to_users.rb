class AddChatimageToUsers < ActiveRecord::Migration
  def change
    add_column :chats, :chatimage_id, :integer
  end
end
