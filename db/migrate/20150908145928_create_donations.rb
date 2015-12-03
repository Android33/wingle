class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.integer :user_id
      t.integer :church_id
      t.float :amount

      t.timestamps
    end
  end
end
