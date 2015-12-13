class AddColumnBirthdayToUserInfo < ActiveRecord::Migration
  def change
    add_column :user_infos, :birthday, :datetime
  end
end
