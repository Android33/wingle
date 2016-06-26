class AddSeenToChats < ActiveRecord::Migration
  def change
    add_column :chats, :seen, :boolean, :default => false
  end
end
