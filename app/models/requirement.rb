class Requirement < ActiveRecord::Base
  validates :target_score, :weight, :usage, :specification, :presence => true
  validates :target_score, :weight , :numericality => {:greater_than_or_equal_to => 0}
  validates :target_score, :numericality => {:less_than_or_equal_to => 10}
  validates :weight , :numericality => {:less_than_or_equal_to => 100}
  belongs_to :specification
  belongs_to :usage

  #builds a hash {:usage_3_spec_12 => {:target_score => 5, :weight => 10}}
  def cached_hash
    Rails.cache.fetch('requirements'){build_requirements_hash}
  end

  def build_requirements_hash
    result = {}
    Requirement.all.each
end
