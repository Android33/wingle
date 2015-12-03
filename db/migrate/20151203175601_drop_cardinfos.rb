class DropCardinfos < ActiveRecord::Migration
  def change
    drop_table :cardinfos
  end
end
