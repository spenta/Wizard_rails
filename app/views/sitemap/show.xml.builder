xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.urlset(:xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9") do
  #home
  sitemap_tag xml, root_url, :freq => 'weekly', :prio => 1.0 
  #catalogue
  sitemap_tag xml, products_url, :freq => 'daily', :prio => 0.9 
  #legal
  sitemap_tag xml, legal_url, :freq => 'yearly', :prio => 0.1 
  #terms
  sitemap_tag xml, terms_url, :freq => 'yearly', :prio => 0.1
  #tour
  sitemap_tag xml, tour_url, :freq => 'monthly', :prio => 0.6 
  #press
  sitemap_tag xml, press_url, :freq => 'press', :prio => 0.6
  #contact
  sitemap_tag xml, contact_url, :freq => 'contact', :prio => 0.2


  #products
  Product.all.each do |p| 
    sitemap_tag xml, product_url(p.to_param), :freq => 'daily', :prio => 0.5
  end
  
  #articles 
  Article.all.each do |a|
    sitemap_tag xml, article_url(a), :freq => 'weekly', :prio => 0.7 
  end
end
