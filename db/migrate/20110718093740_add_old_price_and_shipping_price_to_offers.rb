class AddOldPriceAndShippingPriceToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :old_price, :float
    add_column :offers, :shipping_price, :float
  end

  def self.down
    remove_column :offers, :shipping_price
    remove_column :offers, :old_price
  end
end
