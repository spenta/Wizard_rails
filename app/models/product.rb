class Product < ActiveRecord::Base
  belongs_to :brand
  has_many :specification_values, :through => :products_specs_values
  has_many :products_specs_values
  has_many :offers
  validates :name, :small_img_url, :big_img_url, :brand, :presence => true
  
  def self.all_cached
    Rails.cache.fetch("all_products") {Product.all}
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
    Specification.all.collect{|spec| spec.id}.each do |spec_id|
      infos[:specification_values][spec_id] = build_specification_values_hash spec_id 
    end
    # Name
    infos[:name] = name
    # Brand 
    infos[:brand_name] = brand.name
    # Price
    infos[:price] = build_price
    # Images
    infos[:small_img_url] = small_img_url
    infos[:big_img_url] = big_img_url
    infos
  end

  def build_specification_values_hash specification_id
    specification_values_hash = {}
    psv = ProductsSpecsValue.where(:product_id => id, :specification_id => specification_id).first
    if psv.specification_value_id
      sv = SpecificationValue.find(psv.specification_value_id)
      specification_values_hash[:sv_id] = sv.id
      specification_values_hash[:sv_name] = sv.name
      specification_values_hash[:sv_score] = sv.score
      specification_values_hash
    end
  end

  #gets the minimal price among all offers
  def build_price
    price = self.offers.sort{|o1, o2| o1.price <=> o2.price}.first.price
  end

end
