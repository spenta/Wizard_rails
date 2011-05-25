class ProductsController < ApplicationController
  caches_page :index, :show

  # GET /products
  def index
    unless Rails.cache.read('cache_state') == 'complete'
      clear_products_cache
      build_cache
    end
    @products = Product.all_cached
  end

  # GET /products/pc-portable-acer-truc-1
  def show
    @product = Product.find(params[:id].split('-').last)
  end

  private

  def clear_products_cache
    expire_page :action => :index
    expire_page :action => :show
  end

  def build_cache
    Rails.cache.write('cache_state', 'busy')
    Product.all_cached.each do |p|
      p.infos
    end
    Requirement.usages_requirements
    Requirement.mobilities_requirements
    Specification.all_cached
    Rails.cache.write('cache_state', 'complete')
  end

end
