class AddColumnsToNsettings < ActiveRecord::Migration
  def change
    add_column :nsettings, :sound, :boolean, :default => true
    add_column :nsettings, :vibrate, :boolean, :default => true
    add_column :nsettings, :led, :boolean, :default => true
    add_column :nsettings, :show_my_location, :boolean, :default => true
    add_column :nsettings, :checked_me_out, :boolean, :default => false
  end
end
