class CreateSuperUsages < ActiveRecord::Migration
  def self.up
    create_table :super_usages do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :super_usages
  end
end
