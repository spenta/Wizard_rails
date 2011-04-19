class DropProductsSpecificationValues < ActiveRecord::Migration
  def self.up
    drop_table :products_specification_values
  end

  def self.down
    create_table :products_specification_values, :id => false do |t|
      t.integer :product_id
      t.integer :specification_value_id
    end
  end
end

