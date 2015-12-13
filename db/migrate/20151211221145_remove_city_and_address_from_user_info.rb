class RemoveCityAndAddressFromUserInfo < ActiveRecord::Migration
  def change
    remove_column :user_infos, :city, :string
    remove_column :user_infos, :address, :string
  end
end
