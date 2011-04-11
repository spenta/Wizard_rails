class RenameSpecificationType < ActiveRecord::Migration
  def self.up
    rename_column :specifications, :type, :specification_type
  end

  def self.down
    rename_column :specifications, :specification_type, :type
  end
end
