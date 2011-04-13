class Product < ActiveRecord::Base
  belongs_to :brand
  has_and_belongs_to_many :specification_values
  validates :name, :small_img_url, :big_img_url, :brand, :presence => true
end

