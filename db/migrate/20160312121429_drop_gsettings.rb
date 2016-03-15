class DropGsettings < ActiveRecord::Migration
  def change
    drop_table :gsettings
  end
end
