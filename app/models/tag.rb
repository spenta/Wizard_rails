class Tag < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /[a-zA-Z0-9]+/
end
