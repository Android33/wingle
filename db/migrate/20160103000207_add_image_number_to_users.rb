class AddImageNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_no, :string
  end
end
