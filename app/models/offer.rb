class Offer < ActiveRecord::Base
  validates :price, :retailer, :presence => true
  belongs_to :affiliation_platform
  belongs_to :retailer
  belongs_to :product

  DISCOUNT_THRESHOLD = -0.02

  def to_param
    str = "pc portable"
    str+="-"
    str+= retailer.name
    str+="-"
    str+=retailer_product_name
    str+="-"
    str += id.to_s
    str.gsub(/[\/\ \.\"\'%]/,'-')
  end

  def get_discount_percentage
    if (old_price and old_price > 1)
      discount = (price - old_price)/old_price
    end
    (discount and discount < DISCOUNT_THRESHOLD) ? discount : nil
  end

  def get_discount_absolute
    if price && old_price
      price - old_price
    end
  end

end

