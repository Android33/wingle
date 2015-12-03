class DropParoises < ActiveRecord::Migration
  def change
    drop_table :paroises
  end
end
