class SuperUsage < ActiveRecord::Base
  validates :name, :presence => true
  has_many :usages

  #hash {su_id => [u_id1, u_id2, ...]}
  def self.all_cached_no_mobilities
    Rails.cache.fetch("super_usages_no_mobilities") do
      super_usages_cached = {}
      super_usages = self.all.select{|su| su.name != "Mobilite"}
      super_usages.each do |su|
        super_usages_cached[su.id] = su.usages.collect{|u| u.id} 
      end
      super_usages_cached
    end
  end

  def self.mobilities
    Rails.cache.fetch("mobilities") do 
      super_mobility = SuperUsage.where(:name => "Mobilite").first
      super_mobility.usages.collect{|m| m.id}
    end
  end
end
