class RemoveColumnAgeFromUserInfo < ActiveRecord::Migration
  def up
    remove_column :user_infos, :age
  end
  def down
    add_column :user_infos, :age, :integer
  end
end
