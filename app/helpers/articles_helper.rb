module ArticlesHelper
  def has_tag(article, tag_name)
    raise "no tag name #{tag_name}" unless tag = Tag.where(:name => tag_name).first
    article.tags.all.include?(tag)
  end
end
