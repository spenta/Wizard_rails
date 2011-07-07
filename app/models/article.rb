class Article < ActiveRecord::Base
  belongs_to :user
  has_many :tag_article_associations
  has_many :tags, :through => :tag_article_associations
  validates_presence_of :title_for_head, :title, :summary, :meta, :body, :user, :url
  validates_uniqueness_of :title_for_head, :title, :url
  validates_format_of :url, :with => /\A[a-zA-Z0-9\-_]+\z/, :message => "Only letters allowed"

  #to_param method is overriden in order to have custom url names
  def to_param
    if url
      url.gsub(/[\/\ \.]/,'-')+"-"+id.to_s
    end
  end
end
