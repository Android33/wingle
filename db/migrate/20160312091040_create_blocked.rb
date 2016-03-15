class CreateBlocked < ActiveRecord::Migration
  def change
    create_table :blockeds do |t|
      t.integer :user_id

      t.integer :blocked_user_id

      t.timestamps
    end
    add_index :blockeds, :user_id
  end
end
