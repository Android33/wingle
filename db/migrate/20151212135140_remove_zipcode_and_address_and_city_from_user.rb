class RemoveZipcodeAndAddressAndCityFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :city, :string
    remove_column :users, :zipcode, :string
  end
end
