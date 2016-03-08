class CreateNotificationsTable < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :notification_type
      t.integer :sender_id
      t.integer :receiver_id
      t.timestamps
    end
  end
end
