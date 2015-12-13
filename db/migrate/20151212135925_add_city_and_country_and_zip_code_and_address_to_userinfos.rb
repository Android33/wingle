class AddCityAndCountryAndZipCodeAndAddressToUserinfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :city, :string
    add_column :user_infos, :country, :string
    add_column :user_infos, :zipcode, :string
    add_column :user_infos, :address, :string
  end
end
