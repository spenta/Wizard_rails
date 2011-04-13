class SpecificationValue < ActiveRecord::Base
  belongs_to :specification
  has_and_belongs_to_many :products
  validates :name, :specification_id, :presence => true
end

