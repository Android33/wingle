class AddOrderToImages < ActiveRecord::Migration
  def change
    add_column :images, :order, :integer, default: 0
  end
end
