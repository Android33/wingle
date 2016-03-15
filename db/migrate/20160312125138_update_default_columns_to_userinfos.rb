class UpdateDefaultColumnsToUserinfos < ActiveRecord::Migration
  def up
    change_column :userinfos, :headline, :string, default: ""
    change_column :userinfos, :height, :string, default: "Ask me"
    change_column :userinfos, :body_type, :string, default: "Ask me"
    change_column :userinfos, :ethnicity, :string, default: "Ask me"
    change_column :userinfos, :relation_status, :string, default: "Ask me"
    change_column :userinfos, :about_me, :string, default: ""
  end

  def down
    change_column :userinfos, :headline, :string, default: nil
    change_column :userinfos, :height, :string, default: nil
    change_column :userinfos, :body_type, :string, default: nil
    change_column :userinfos, :ethnicity, :string, default: nil
    change_column :userinfos, :relation_status, :string, default: nil
    change_column :userinfos, :about_me, :string, default: nil
  end
end
