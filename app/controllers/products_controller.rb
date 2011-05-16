class ProductsController < ApplicationController
  caches_page :index, :show

  # GET /products
  def index
    @products = Product.all_cached
  end

  # GET /products/1
  def show
    @product = Product.find(params[:id])
  end
end
