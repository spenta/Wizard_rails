class CreateProductsSpecificationValues < ActiveRecord::Migration
  def self.up
    create_table :products_specification_values, :id => false do |t|
      t.integer :product_id
      t.integer :specification_value_id
    end
  end

  def self.down
    drop_table :products_specification_values
  end
end

