class Specification < ActiveRecord::Base
  validates :name, :specification_type, :presence => true
  validates :specification_type, :format => /discrete|continuous|not_marked/
end
