class ApplicationController < ActionController::Base
  include WizardUtilities
  protect_from_forgery
  before_filter :set_locale, :check_cache
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    I18n.locale = params[:locale]
  end

  def check_cache
    unless Rails.cache.read('cache_state') == 'complete'
      build_cache
    end
  end

  helper_method :current_user

  private

  def build_cache
    Rails.cache.write('cache_state', 'busy')
    Product.all_cached.each do |p|
      p.infos
    end
    Requirement.usages_requirements
    Requirement.mobilities_requirements
    Specification.all_cached
    USER_PROFILES_CONFIG.each_key do |profile|
      build_response_for_user_profile profile
    end
    Rails.cache.write('cache_state', 'complete')
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

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
