class AddIsAccountActiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_account_active, :boolean, :default => true
  end
end
