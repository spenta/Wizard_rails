class Offer < ActiveRecord::Base
  validates :price, :retailer, :presence => true
  belongs_to :affiliation_platform
  belongs_to :retailer
  belongs_to :product

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
end

