class Offer < ActiveRecord::Base
  validates :price, :retailer, :presence => true
  belongs_to :affiliation_platform
  belongs_to :retailer
  belongs_to :product
end

