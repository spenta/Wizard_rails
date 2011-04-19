class ProductsSpecsValue < ActiveRecord::Base
  belongs_to :product
  belongs_to :specification_value
end

