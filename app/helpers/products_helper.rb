module ProductsHelper

  def offers_number_text
    count = @product.offers.count
    text = t_safe :product_offers_number_1
    text += " "
    text += count.to_s
    text += " "
    if count == 1
      text += t :product_offers_number_2_singular
    else
      text += t :product_offers_number_2_plural
    end
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

  def retailer_product_name offer
    offer.retailer_product_name || "#{infos[:brand_name]} #{infos[:name]}"
  end

  def link_to_offer offer, product
    if root_url == "http://www.choisirfacile.com/"
      link_to offer, :target => "_blank", :onClick => "_gaq.push(['_trackEvent', 'retailer_clicks', 'buy', \'buy-#{product.to_param}-#{offer.retailer.name}\']);" do
        yield
      end
    else
      link_to offer, :target => "_blank" do
        yield
      end
    end
  end

  def usage_class_generator product
    if product.infos[:specification_values][3][:sv_score] <= 5
    # GPU = low

      if product.infos[:specification_values][11][:sv_score] <= 4

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = low, CPU = low, RAM = low
          t_safe :usage_class_l_l_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7.5
        # GPU = low, CPU = low, RAM = medium
          t_safe :usage_class_l_l_m
        else
        # GPU = low, CPU = low, RAM = high
          t_safe :usage_class_l_l_h
        end

      elsif product.infos[:specification_values][11][:sv_score] > 4 and product.infos[:specification_values][11][:sv_score] <= 7

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = low, CPU = medium, RAM = low
          t_safe :usage_class_l_m_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7.5
        # GPU = low, CPU = medium, RAM = medium
          t_safe :usage_class_l_m_m
        else
        # GPU = low, CPU = medium, RAM = high
          t_safe :usage_class_l_m_h
        end

      else

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = low, CPU = high, RAM = low
          t_safe :usage_class_l_h_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7.5
        # GPU = low, CPU = high, RAM = medium
          t_safe :usage_class_l_h_m
        else
        # GPU = low, CPU = high, RAM = high
          t_safe :usage_class_l_h_h
        end
      end


    elsif product.infos[:specification_values][3][:sv_score] > 5 and product.infos[:specification_values][3][:sv_score] <= 7.5
      # GPU = medium

      if product.infos[:specification_values][11][:sv_score] <= 4

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = medium, CPU = low, RAM = low
          t_safe :usage_class_m_l_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7.5
        # GPU = medium, CPU = low, RAM = medium
          t_safe :usage_class_m_l_m
        else
        # GPU = medium, CPU = low, RAM = high
          t_safe :usage_class_m_l_h
        end

      elsif product.infos[:specification_values][11][:sv_score] > 4 and product.infos[:specification_values][11][:sv_score] < 7

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = medium, CPU = medium, RAM = low
          t_safe :usage_class_m_m_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] <= 7.5
        # GPU = medium, CPU = medium, RAM = medium
          t_safe :usage_class_m_m_m
        else
        # GPU = medium, CPU = medium, RAM = high
          t_safe :usage_class_m_m_h
        end

      else

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = medium, CPU = high, RAM = low
          t_safe :usage_class_m_h_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7
        # GPU = medium, CPU = high, RAM = medium
          t_safe :usage_class_m_h_m
        else
        # GPU = medium, CPU = high, RAM = high
          t_safe :usage_class_m_h_h
        end
      end


    else
      # GPU = high

      if product.infos[:specification_values][11][:sv_score] <= 4

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = high, CPU = low, RAM = low
          t_safe :usage_class_h_l_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7.5
        # GPU = high, CPU = low, RAM = medium
          t_safe :usage_class_h_l_m
        else
        # GPU = high, CPU = low, RAM = high
          t_safe :usage_class_h_l_h
        end

      elsif product.infos[:specification_values][11][:sv_score] > 4 and product.infos[:specification_values][11][:sv_score] < 7

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = high, CPU = medium, RAM = low
          t_safe :usage_class_h_m_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7.5
        # GPU = high, CPU = medium, RAM = medium
          t_safe :usage_class_h_m_m
        else
        # GPU = high, CPU = medium, RAM = high
          t_safe :usage_class_h_m_h
        end

      else

        if product.infos[:specification_values][2][:sv_score] <= 4
        # GPU = high, CPU = high, RAM = low
          t_safe :usage_class_h_h_l
        elsif product.infos[:specification_values][2][:sv_score] > 4 and product.infos[:specification_values][3][:sv_score] < 7.5
        # GPU = high, CPU = high, RAM = medium
          t_safe :usage_class_h_h_m
        else
        # GPU = high, CPU = high, RAM = high
          t_safe :usage_class_h_h_h
        end
      end

    end
  end

  def storage_class_generator product
    if product.infos[:specification_values][4][:sv_score] <= 3.5
      t_safe :storage_class_l
    elsif product.infos[:specification_values][4][:sv_score] > 3.5 and product.infos[:specification_values][4][:sv_score] < 6.5
      t_safe :storage_class_m
    else
      t_safe :storage_class_h
    end
  end

  def weight_class_generator product
    if product.infos[:specification_values][9][:sv_score] > 7
      t_safe :weight_class_l
    elsif product.infos[:specification_values][9][:sv_score] > 3.5 and product.infos[:specification_values][9][:sv_score] <= 7
      t_safe :weight_class_m
    else
      t_safe :weight_class_h
    end
  end

  def retailers_with_no_offers product
    retailer_with_offers = []
    product.offers.each {|o| retailer_with_offers << o.retailer unless retailer_with_offers.include?(o.retailer)  }
    Retailer.all.select{|r| !retailer_with_offers.include?(r)}
  end
end

