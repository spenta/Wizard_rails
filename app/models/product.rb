class Product < ActiveRecord::Base
  belongs_to :brand
  has_many :specification_values, :through => :products_specs_values
  has_many :products_specs_values
  has_many :offers
  validates :name, :brand, :presence => true
  
  #to_param method is overriden in order to have custom url names
  def to_param brand_name, product_name
    str = "pc-portable-"
    str += brand_name
    str += "-"
    str += product_name
    str += "-"
    str += id.to_s
    str.gsub(/[\/\ \.]/,'-')
  end

  def self.all_cached
    products = Product.all.select{|p| p.price>0 and p.infos[:has_image]}
    Rails.cache.fetch("all_products") {products}
  end

  def price
    infos[:price]
  end

  def infos
    Rails.cache.fetch("product_infos_#{id}") {build_infos}
  end

  def build_infos
    infos = {}
    # Specification values
    infos[:specification_values] = {}
    Specification.all_cached.collect{|spec| spec.id}.each do |spec_id|
      infos[:specification_values][spec_id] = build_specification_values_hash spec_id 
    end
    # Name
    infos[:name] = name
    # Brand 
    brand_name = brand.name
    infos[:brand_name] = brand_name
    # Price
    best_price_and_retailer = get_best_price_and_retailer
    infos[:price] = best_price_and_retailer[:best_price]
    infos[:cheapest_retailer_id] = best_price_and_retailer[:cheapest_retailer_id]
    infos[:best_offer_id] = best_price_and_retailer[:best_offer_id]
    # Images
    infos[:has_image] = true
    infos[:small_img_url] = small_img_url
    infos[:big_img_url] = big_img_url
    if infos[:small_img_url] == "" or infos[:small_img_url].nil?
      infos[:small_img_url] = "/images/product/not_available.png" 
      infos[:has_image] = false
    end
    if infos[:big_img_url] == "" or infos[:big_img_url].nil?
      infos[:big_img_url] = "/images/product/not_available_big.png" 
      infos[:has_image] = false
    end
    infos[:to_param] = to_param(brand_name, name)
    infos
  end

  def build_specification_values_hash specification_id
    specification_values_hash = {}
    psv = ProductsSpecsValue.where(:product_id => id, :specification_id => specification_id).first
    if psv.specification_value_id
      if psv.specification_value_id == 0
        specification_values_hash[:sv_id] = 0 
        specification_values_hash[:sv_name] = I18n.t :not_communicated 
        specification_values_hash[:sv_score] = 0
        specification_values_hash[:sv_is_exact] = false
      else
        sv = SpecificationValue.find(psv.specification_value_id)
        specification_values_hash[:sv_id] = sv.id
        specification_values_hash[:sv_name] = sv.name
        specification_values_hash[:sv_score] = sv.score
        specification_values_hash[:sv_is_exact] = (psv.source_id != 2)
      end
      specification_values_hash
    end
  end

  #gets the minimal price among all offers
  def get_best_price_and_retailer
    result={}
    if self.offers.count > 0
      best_offer = self.offers.sort{|o1, o2| o1.price <=> o2.price}.first
      result = {:best_price => best_offer.price, :best_offer_id => best_offer.id, :cheapest_retailer_id => best_offer.retailer_id}
    else
      result={:best_price => 0, :best_offer_id => "none", :cheapest_retailer => "none"}
    end  
  end

end
