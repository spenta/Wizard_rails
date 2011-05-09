class ChangeProductSpecScoresName < ActiveRecord::Migration
  def self.up
    rename_table :product_spec_scores, :products_specs_scores
  end

  def self.down
    rename_table :products_specs_scores, :product_spec_scores
  end
end
