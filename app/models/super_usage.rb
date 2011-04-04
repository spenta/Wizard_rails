class SuperUsage < ActiveRecord::Base
  validates :name, :presence => true
  has_many :usages
end
