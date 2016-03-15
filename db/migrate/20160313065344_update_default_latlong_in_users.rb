class UpdateDefaultLatlongInUsers < ActiveRecord::Migration
  def up
    change_column :users, :latitude, :float, default: 0.0
    change_column :users, :longitude, :float, default: 0.0
  end

  def down
    change_column :users, :latitude, :float, default: nil
    change_column :users, :longitude, :float, default: nil
  end
end
