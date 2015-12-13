class AddCityAndCountryAndZipcodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :city, :string
    add_column :users, :country, :string
    add_column :users, :zipcode, :string
  end
end
