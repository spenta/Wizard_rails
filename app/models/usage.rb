class Usage < ActiveRecord::Base
  validates :name, :presence => true
  belongs_to :super_usage
  has_many :requirements
  has_many :usage_choices
end
