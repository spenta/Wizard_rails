class Usage < ActiveRecord::Base
  validates :name, :presence => true
  belongs_to :super_usage
end
