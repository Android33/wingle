class RemoveTypeFromRpayment < ActiveRecord::Migration
  def change
    remove_column :rpayments, :type, :string
  end
end
