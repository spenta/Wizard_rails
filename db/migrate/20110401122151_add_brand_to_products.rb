class AddBrandToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :brand, :references
  end

  def self.down
    remove_column :products, :brand
  end
end
