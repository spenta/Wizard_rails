class CreateRequirements < ActiveRecord::Migration
  def self.up
    create_table :requirements do |t|
      t.float :target_score
      t.float :weight
      t.references :specification
      t.references :usage

      t.timestamps
    end
  end

  def self.down
    drop_table :requirements
  end
end
