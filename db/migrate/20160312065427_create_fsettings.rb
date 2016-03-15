class CreateFsettings < ActiveRecord::Migration
  def change
    create_table :fsettings do |t|
      t.integer :user_id
      t.string  :show_me_of_gende_with_interest, :default => C::FSettings::SHOW_ME_OF_GENDER_WITH_INTEREST[:SHOW_ME_ALL]
      t.string  :show_me_close_to, :default => C::FSettings::SHOW_ME_CLOSE_TO[:SHOW_ME_CLOSE_TO_HERE]
      t.string  :show_me_of_age_min, :default => C::FSettings::SHOW_ME_OF_AGE[:SHOW_ME_OF_AGE_MIN_DEFAULT]
      t.string  :show_me_of_age_max, :default => C::FSettings::SHOW_ME_OF_AGE[:SHOW_ME_OF_AGE_MAX_DEFAULT]
      t.string  :show_me_of_city
      t.string  :show_me_of_ethnicity, :default => C::FSettings::SHOW_ME_OF_ETHNICITY[:ETHNICITY_ALL]

      t.timestamps
    end
    add_index :fsettings, :user_id
  end
end
