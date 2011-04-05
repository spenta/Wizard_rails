class UsageChoice < ActiveRecord::Base
  validates :weight_for_user, :usage, :user_request, :presence => true
  validates :weight_for_user, :numericality => {:greater_than_or_equal_to => 0}
  validates :weight_for_user, :numericality => {:less_than_or_equal_to => 100}
  
  belongs_to :usage
  belongs_to :user_request
end
