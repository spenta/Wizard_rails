class Product < ActiveRecord::Base
  belongs_to :brand
  validates :name, :small_img_url, :big_img_url, :brand, :presence => true
end
