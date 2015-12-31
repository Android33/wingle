class FixImageName < ActiveRecord::Migration
  def self.up
    rename_column :images, :image_url, :img
  end

  def self.down
    rename_column :images, :img, :image_url
    # rename back if you need or do something else or do nothing
  end
end
