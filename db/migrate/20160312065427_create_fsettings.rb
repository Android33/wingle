class CreateFsettings < ActiveRecord::Migration
  def change
    create_table :fsettings do |t|
      t.integer :user_id
      t.string  :show_me_of_gende_with_interest, :default => 'Everybody'
      t.string  :show_me_close_to, :default => 'SHOW_ME_CLOSE_TO_HERE'
      t.string  :show_me_of_age_min, :default => '18'
      t.string  :show_me_of_age_max, :default => '45'
      t.string  :show_me_of_city
      t.string  :show_me_of_ethnicity, :default => 'ALL'

      t.timestamps
    end
    add_index :fsettings, :user_id
  end
end
