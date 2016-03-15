class RenameShowMeInFsettings < ActiveRecord::Migration
  def change
    rename_column :fsettings, :show_me_of_gende_with_interest, :show_me_of_gender_with_interest
  end
end
