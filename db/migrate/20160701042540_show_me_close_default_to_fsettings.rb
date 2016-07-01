class ShowMeCloseDefaultToFsettings < ActiveRecord::Migration
  def up
    change_column :fsettings, :show_me_close_to, :string, default: 'SHOW_ME_CLOSE_TO_WORLD'
  end

  def down
    change_column :userinfos, :headline, :string, default: 'SHOW_ME_CLOSE_TO_HERE'
  end
end
