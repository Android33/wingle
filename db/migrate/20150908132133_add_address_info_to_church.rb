class AddAddressInfoToChurch < ActiveRecord::Migration
  def change
    add_column :churches, :city, :string
    add_column :churches, :zip, :string
    add_column :churches, :address, :string
  end
end
