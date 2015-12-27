class CreateNsettings < ActiveRecord::Migration
  def change
    create_table :nsettings do |t|
      ## For one to one relation with user
      t.integer :user_id

      t.boolean :favorite_me, default: true
      t.boolean :msg_alert, default: true
      t.boolean :wingle_alert, default: true
      t.boolean :member_alert, default: true

      t.timestamps
    end
    add_index :nsettings, :user_id
  end
end
