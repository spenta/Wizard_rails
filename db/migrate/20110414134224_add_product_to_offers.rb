class AddProductToOffers < ActiveRecord::Migration
  def self.up
    change_table :offers do |t|
      t.references :product
    end
  end

  def self.down
    remove_column :offers, :product
  end
end

