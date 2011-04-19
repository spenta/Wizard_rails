class CreateProductsSpecsValues < ActiveRecord::Migration
  def self.up
    create_table :products_specs_values do |t|
      t.references :product
      t.references :specification
      t.references :specification_value
      t.integer :sourceId

      t.timestamps
    end
  end

  def self.down
    drop_table :products_specs_values
  end
end

