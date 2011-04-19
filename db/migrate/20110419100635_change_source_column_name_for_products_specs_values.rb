class ChangeSourceColumnNameForProductsSpecsValues < ActiveRecord::Migration
  def self.up
    rename_column :products_specs_values, :sourceId, :source_id
  end

  def self.down
    rename_column :products_specs_values, :source_id, :sourceId
  end
end

