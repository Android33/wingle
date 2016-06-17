class AddResetTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :resettoken, :string
  end
end
