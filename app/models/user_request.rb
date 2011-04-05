class UserRequest < ActiveRecord::Base
  validates :order_by, :format => /spenta_score|price|name|brand/
  validates :num_result, :start_index , :numericality => {:greater_than_or_equal_to => 0}
  has_many :usage_choices, :dependent => :destroy
end
