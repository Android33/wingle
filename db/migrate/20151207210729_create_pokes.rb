class CreatePokes < ActiveRecord::Migration
  def change
    create_table :pokes do |t|
      ## For one to many relation with user
      t.integer :user_id

      t.integer :poke_count, default: 0
      t.integer :poked_user_id

      t.timestamps
    end
    add_index :pokes, :user_id
  end
end
