class Requirement < ActiveRecord::Base
  validates :target_score, :weight, :usage, :specification, :presence => true
  validates :target_score, :weight , :numericality => {:greater_than_or_equal_to => 0}
  validates :target_score, :numericality => {:less_than_or_equal_to => 10}
  validates :weight , :numericality => {:less_than_or_equal_to => 100}
  belongs_to :specification
  belongs_to :usage
end
