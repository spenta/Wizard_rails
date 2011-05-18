module ProductsHelper
  def offers_number_text
    text = t :product_offers_number_1
    text += " "
    text += @product.offers.count.to_s
    text += " "
    text += t :product_offers_number_2
    text += " "
    text += Retailer.count.to_s
    text += " "
    text += t :product_offers_number_3
  end

  def product_sold_by infos, retailer_name
    text = t :product_laptop
    text += " "
    text += infos[:brand_name]
    text += " "
    text += infos[:name]
    text += " "
    text += t :product_sold_by
    text += " "
    text += retailer_name
  end

  def parameters_for_left_table
    {t(:product_table_cpu_ram_hdd) => [11, 2, 4],
     t(:product_table_mobility) => [9, 84, 10],
     t(:product_table_network) => [23, 15, 46],
     t(:product_table_tv) => [18, 19, 17]}
  end


  def parameters_for_right_table
    {t(:product_table_display) => [5, 31, 6, 3, 33, 7],
     t(:product_table_wires) => [39, 16, 14],
     t(:product_table_extras) => [20, 12, 40, 32]}
  end

end
