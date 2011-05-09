class ProductsSpecsScore < ActiveRecord::Base
  belongs_to :product
  belongs_to :specification
end
