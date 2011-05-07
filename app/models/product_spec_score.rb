class ProductSpecScore < ActiveRecord::Base
  belongs_to :product
  belongs_to :specification
end
