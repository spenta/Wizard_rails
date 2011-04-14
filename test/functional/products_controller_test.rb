require 'test_helper'
class ProductsControllerTest < ActionController::TestCase
  fixtures :products, :brands
  setup do
    @product = products(:product_76)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should show product" do
    get :show, :id => @product.to_param
    assert_response :success
  end
end

