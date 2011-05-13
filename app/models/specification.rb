class Specification < ActiveRecord::Base
  validates :name, :specification_type, :presence => true
  validates :specification_type, :format => /discrete|continuous|not_marked/
  has_many :requirements

  def self.all_cached
    Rails.cache.fetch('all_specifications'){Specification.all}
  end
end
