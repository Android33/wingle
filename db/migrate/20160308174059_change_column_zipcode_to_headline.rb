class ChangeColumnZipcodeToHeadline < ActiveRecord::Migration
  def change
    rename_column :userinfos, :zipcode, :headline
  end
end
