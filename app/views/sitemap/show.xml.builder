xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
  #home
  sitemap_tag xml, root_url, :freq => 'weekly', :prio => 1.0 
  #catalogue
  sitemap_tag xml, products_url, :freq => 'daily', :prio => 0.9 
  #legal & terms
  sitemap_tag xml, legal_url, :freq => 'yearly', :prio => 0.1 
  sitemap_tag xml, terms_url, :freq => 'yearly', :prio => 0.1

  #products
  Product.all.each do |p| 
    sitemap_tag xml, product_url(p.to_param), :freq => 'daily'
  end
  
end
