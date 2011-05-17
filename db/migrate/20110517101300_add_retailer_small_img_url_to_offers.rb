class AddRetailerSmallImgUrlToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :retailer_small_img_url, :text
  end

  def self.down
    remove_column :offers, :retailer_small_img_url
  end
end
