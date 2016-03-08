class ChangeHeightTypeInUserinfos < ActiveRecord::Migration
  def up
    change_column :userinfos, :height, :string
  end

  def down
    change_column :userinfos, :height, :decimal
  end
end
