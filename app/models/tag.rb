class Tag < ActiveRecord::Base
  has_many :tag_article_associations
  has_many :articles, :through => :tag_article_associations
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /^[a-zA-Z0-9]+$/
end
