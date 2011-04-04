require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products, :brands 
  test "product should be valid" do
    valid_product = Product.new(:name => products(:toshiba_satellite).name,
                                :small_img_url => products(:toshiba_satellite).small_img_url,
                                :big_img_url => products(:toshiba_satellite).big_img_url,
                                :brand => products(:toshiba_satellite).brand)
    assert valid_product.valid?
  end
  
  test "product should have a name" do
    product_without_name = Product.new(:small_img_url => products(:toshiba_satellite).small_img_url,
                                :big_img_url => products(:toshiba_satellite).big_img_url,
                                :brand => products(:toshiba_satellite).brand)
    assert product_without_name.invalid?
  end
  
  test "product should have a small_img_url" do
    product_without_small_url = Product.new(:name => products(:toshiba_satellite).name,
                                :big_img_url => products(:toshiba_satellite).big_img_url,
                                :brand => products(:toshiba_satellite).brand)
    assert product_without_small_url.invalid?
  end
  
  test "product should have a big_img_url" do
    product_without_big_url = Product.new(:name => products(:toshiba_satellite).name,
                                :small_img_url => products(:toshiba_satellite).small_img_url,
                                :brand => products(:toshiba_satellite).brand)
    assert product_without_big_url.invalid?
  end
  
  test "product should have a brand" do
    product_without_brand = Product.new(:name => products(:toshiba_satellite).name,
                                :small_img_url => products(:toshiba_satellite).small_img_url,
                                :big_img_url => products(:toshiba_satellite).big_img_url)
    assert product_without_brand.invalid?
  end
  
  test "product should have a valid brand" do
    product_without_valid_brand = Product.new(:name => products(:toshiba_satellite).name,
                                :small_img_url => products(:toshiba_satellite).small_img_url,
                                :big_img_url => products(:toshiba_satellite).big_img_url,
                                :brand_id => 0)
    assert product_without_valid_brand.invalid?
  end
end
