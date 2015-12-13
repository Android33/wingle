class CreateUserInfos < ActiveRecord::Migration
  def change
    create_table :user_infos do |t|
      ## For one to one relation with user
      t.integer :user_id

      t.string :gender, default: ""
      t.integer :age, default: 0
      t.string :address
      t.string :city
      t.decimal :height
      t.string :ethnicity
      t.string :body_type
      t.string :relation_status
      t.string :interested_in
      t.text :about_me
      t.string :wingle_id

      t.timestamps
    end
    add_index :user_infos, :user_id
  end
end
