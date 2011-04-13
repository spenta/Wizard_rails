class CreateSpecificationValues < ActiveRecord::Migration
  def self.up
    create_table :specification_values do |t|
      t.string :name
      t.float :score
      t.references :specification

      t.timestamps
    end
  end

  def self.down
    drop_table :specification_values
  end
end
