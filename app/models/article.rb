class Article < ActiveRecord::Base
  belongs_to :user
  has_many :tag_article_associations
  has_many :tags, :through => :tag_article_associations
  validates_presence_of :title, :summary, :meta, :body, :user
end
