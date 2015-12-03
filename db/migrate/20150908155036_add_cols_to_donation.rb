class AddColsToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :type, :string
    add_column :donations, :recuring, :boolean
    add_column :donations, :seen, :boolean
  end
end
