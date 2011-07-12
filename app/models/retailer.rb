class Retailer < ActiveRecord::Base
  validates :name, :presence => true
  has_many :offers

  def self.all_cached
    Rails.cache.fetch('all_retailers'){self.all}
  end

end
