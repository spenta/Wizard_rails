class ProductsController < ApplicationController
  include WizardUtilities
  #caches_page :index

  # GET /products
  def index
    unless Rails.cache.read('cache_state') == 'complete'
      #clear_products_cache
      build_cache
    end
    @products = Product.all_cached
  end

  # GET /products/pc-portable-acer-truc-1
  def show
    @product = Product.find(params[:id].split('-').last)
  end

  private

  #def clear_products_cache
    #expire_page :action => :index
  #end

  def build_cache
    Rails.cache.write('cache_state', 'busy')
    Product.all_cached.each do |p|
      p.infos
    end
    Requirement.usages_requirements
    Requirement.mobilities_requirements
    Specification.all_cached
    Rails.cache.write('cache_state', 'complete')
    USER_PROFILES_CONFIG.each_key do |profile|
      puts USER_PROFILES_CONFIG.inspect
      build_response_for_user_profile profile
    end
  end

  def build_response_for_user_profile profile
    user_request = UserRequest.new
    user_request.usage_choices = []
    USER_PROFILES_CONFIG[profile].each_value do |v|
      user_request.usage_choices << UsageChoice.new(v)
    end
    load 'user_response.rb'
    director = UserResponseDirector.new
    director.init_builder user_request 
    director.process_response
    user_response = director.get_response
    director.clear!
    profile_hash = {}
    profile_hash[:star_products] = sort_by_q(user_response.get_star_products).collect{|p| {:product_id => p.product_id, :score => p.spenta_score}}
    profile_hash[:good_deal_products] = sort_by_q(user_response.get_good_deal_products).collect{|p| {:product_id => p.product_id, :score => p.spenta_score}}
    Rails.cache.write("#{profile}_profile", profile_hash)
  end

end
