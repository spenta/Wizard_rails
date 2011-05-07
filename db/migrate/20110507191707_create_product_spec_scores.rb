class CreateProductSpecScores < ActiveRecord::Migration
  def self.up
    create_table :product_spec_scores do |t|
      t.references :product
      t.references :specification
      t.float :score

      t.timestamps
    end
  end

  def self.down
    drop_table :product_spec_scores
  end
end
