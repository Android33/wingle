class DropChurches < ActiveRecord::Migration
  def change
    drop_table :churches
  end
end
