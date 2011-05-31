xml.urlset do
  #home
  sitemap_tag xml, root_url, :freq => 'weekly', :prio => 1.0 
  #catalogue
  sitemap_tag xml, products_url, :prio => 0.9 
  #legal & terms
  sitemap_tag xml, legal_url, :freq => 'yearly', :prio => 0.1 
  sitemap_tag xml, terms_url, :freq => 'yearly', :prio => 0.1

  #products
  Product.all.each do |p| 
    sitemap_tag xml, product_url(p.to_param)
  end
  
end
