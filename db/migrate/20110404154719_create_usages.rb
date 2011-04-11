class CreateUsages < ActiveRecord::Migration
  def self.up
    create_table :usages do |t|
      t.string :name
      t.references :super_usage

      t.timestamps
    end
  end

  def self.down
    drop_table :usages
  end
end
