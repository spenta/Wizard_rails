class AddBrandToProducts < ActiveRecord::Migration
  def self.up
    change_table :products do |t|
      t.references :brand
    end
  end

  def self.down
  end
end
