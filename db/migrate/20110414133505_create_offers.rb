class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.float :price
      t.text :link
      t.references :affiliation_platform
      t.references :retailer

      t.timestamps
    end
  end

  def self.down
    drop_table :offers
  end
end
