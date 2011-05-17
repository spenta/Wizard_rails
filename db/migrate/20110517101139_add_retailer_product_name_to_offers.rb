class AddRetailerProductNameToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :retailer_product_name, :string
  end

  def self.down
    remove_column :offers, :retailer_product_name
  end
end
