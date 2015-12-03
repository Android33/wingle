class DropRpayments < ActiveRecord::Migration
  def change
    drop_table :rpayments
  end
end
