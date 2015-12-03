class AddCategoryToRpayment < ActiveRecord::Migration
  def change
    add_column :rpayments, :category, :string
  end
end
