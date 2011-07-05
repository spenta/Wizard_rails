class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index(:products_specs_values, :product_id)
    add_index(:products_specs_values, :specification_id)
    add_index(:offers, :product_id)
    add_index(:products, :brand_id)
  end

  def self.down
    remove_index(:products_specs_values, :product_id)
    remove_index(:products_specs_values, :specification_id)
    remove_index(:offers, :product_id)
    remove_index(:products, :brand_id)
  end
end
