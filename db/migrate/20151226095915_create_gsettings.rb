class CreateGsettings < ActiveRecord::Migration
  def change
    create_table :gsettings do |t|
      ## For one to one relation with user
      t.integer :user_id

      t.boolean :sound, default: true
      t.boolean :vibration, default: true
      t.boolean :notification, default: true
      t.boolean :led, default: true

      t.timestamps
    end
    add_index :gsettings, :user_id
  end
end
