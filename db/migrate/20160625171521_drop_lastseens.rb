class DropLastseens < ActiveRecord::Migration
  def change
    drop_table :lastchatseens
  end
end
