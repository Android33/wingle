class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      ## For one to many relation with user
      t.integer :user_id

      t.integer :fav_user_id

      t.timestamps
    end
    add_index :favourites, :user_id
  end
end
