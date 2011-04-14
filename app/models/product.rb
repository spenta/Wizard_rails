class Product < ActiveRecord::Base
  belongs_to :brand
  has_and_belongs_to_many :specification_values
  has_many :offers
  validates :name, :small_img_url, :big_img_url, :brand, :presence => true
end

