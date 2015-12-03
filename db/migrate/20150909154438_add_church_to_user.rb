class AddChurchToUser < ActiveRecord::Migration
  def change
    add_column :users, :church_id, :integer
  end
end
