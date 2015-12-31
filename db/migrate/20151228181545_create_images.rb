class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :image_url
      t.integer :user_id
      t.integer :user_img_count, default: 0
      t.timestamps
    end
    add_index :images, :user_id
  end
end
