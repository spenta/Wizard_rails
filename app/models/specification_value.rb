class SpecificationValue < ActiveRecord::Base
  belongs_to :specification
  has_many :products, :through => :products_specs_values
  has_many :products_specs_values
  validates :name, :specification_id, :presence => true
end

