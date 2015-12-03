class AddLatLngToChurch < ActiveRecord::Migration
  def change
    add_column :churches, :latitude, :float
    add_column :churches, :longitude, :float
  end
end
