module SitemapHelper
  def sitemap_tag xml, path, options={:prio=> 0.5}
    xml.url do
      xml.loc(path)
      xml.changefreq(options[:freq])
      xml.priority(options[:prio])
    end 
  end
end
