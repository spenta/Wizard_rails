class ProductsController < ApplicationController
  caches_page :index

  # GET /products
  # GET /products.xml
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @product = Product.find(params[:id])
  end
end
