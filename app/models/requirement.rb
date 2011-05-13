class Requirement < ActiveRecord::Base
  validates :target_score, :weight, :usage, :specification, :presence => true
  validates :target_score, :weight , :numericality => {:greater_than_or_equal_to => 0}
  validates :target_score, :numericality => {:less_than_or_equal_to => 10}
  validates :weight , :numericality => {:less_than_or_equal_to => 100}
  belongs_to :specification
  belongs_to :usage

  #builds a hash {mobility_id => {spec_id => {:target_score => 5, :weight => 10}}}
  def self.mobilities_requirements
    Rails.cache.fetch('mobility_requirements'){self.build_requirements_hash_for "mobilities"}
  end

  #builds a hash {:usage_id => {spec_id => {:target_score => 5, :weight => 10}}}
  def self.usages_requirements  
    Rails.cache.fetch('usages_requirements') do
      result = {}
      SuperUsage.all.each do |su|
        #handling of usages
        if su.name != 'Mobilite'
          su.usages.each do |u|
            result[u.id] = self.build_usage_hash u
          end
        end
      end
      result
    end
  end

  def self.build_requirements_hash_for type
    result = {}
    SuperUsage.all.each do |su|
      #handling of mobilities
      if su.name == 'Mobilite' and type == "mobilities"
        su.usages.each do |m|
          result[m.id] = self.build_usage_hash m
        end
      #handling of usages
      elsif su.name != 'Mobilite' and type == "usages"
        su.usages.each do |u|
          result[u.id] = self.build_usage_hash u
        end
      end
    end
    result
  end

  def self.build_usage_hash usage
    result = {}
    usage.requirements.each do |r|
      req_hash = {}
      req_hash[:target_score] = r.target_score
      req_hash[:weight] = r.weight
      result[r.specification_id] = req_hash
    end
    result
  end
end
