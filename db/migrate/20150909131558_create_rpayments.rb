class CreateRpayments < ActiveRecord::Migration
  def change
    create_table :rpayments do |t|
      t.integer :user_id
      t.integer :church_id
      t.float :amount
      t.integer :frequency
      t.string :type

      t.timestamps
    end
  end
end
