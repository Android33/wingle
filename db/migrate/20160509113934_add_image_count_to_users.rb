class AddImageCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :imagecount, :integer, :default => 0
  end
end
