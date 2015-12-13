class DeleteChurchIdFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :church_id
  end
end
