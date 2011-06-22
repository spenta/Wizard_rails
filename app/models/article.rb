class Article < ActiveRecord::Base
  belongs_to :user
  has_many :tags, :through => :tag_article_associations
end
