require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products, :brands

  setup do
    @product = products(:product_76).dup
  end

  test "product should be valid" do
    valid_product = @product
    assert valid_product.valid?
  end

  test "product should have a name" do
    @product.name = nil
    assert @product.invalid?
    @product.name = 'test'
    assert @product.valid?
  end

  test "product should have a small_img_url" do
    @product.small_img_url = nil
    assert @product.invalid?
    @product.small_img_url = 'test'
    assert @product.valid?
  end

  test "product should have a big_img_url" do
    @product.big_img_url = nil
    assert @product.invalid?
    @product.big_img_url = 'test'
    assert @product.valid?
  end

  test "product should have a brand" do
    @product.brand = nil
    assert @product.invalid?
  end

end

