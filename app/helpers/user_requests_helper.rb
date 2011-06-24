module UserRequestsHelper
  include WizardUtilities

  #thresholds for colors display, in proportion on value corresponding to a "right" value
  COLOR_THRESHOLDS_RELATIVE = [0, 0.5, 0.7, 0.8, 0.9, 1.1, 1.3, 1.6, 2]
  COLOR_THRESHOLDS_ABSOLUTE = [-6, -4, -2, -1, 0, 1, 2, 4, 7]

  def sortable column, title = nil
    title ||= column.titleize
    direction = column == params[:sort] && params[:direction] == "desc" ? "asc" :"desc"
    link_to title, :sort => column, :direction => direction, :start_index => 0, :num_result => params[:num_result]
  end

  def get_important_specs_id_from gammas
    gamma_array = gammas.to_a
    #sort by descending value
    gamma_array.sort! {|s2, s1| s1[1] <=> s2[1]}
    #only keeps positive gammas
    gamma_array = gamma_array.select {|s| s[1]>0}
    #array or spec_id by descending importance
    result = gamma_array.collect{|s| s[0]}.first(5)
    #complete with default important specs. In order
    # Screen size (specification_id 5)
    # CPU (specification_id 11)
    # Weight (specification_id 9)
    # RAM (specification_id 2)
    # HDD (specification_id 4)
    default_specs = [5, 11, 9, 2, 4]
    default_specs.reverse!
    complete result, :with => default_specs, :until_size_is => 5, :allowing_duplicate => false
    result
  end

  def get_percentage_from score, score_recommended
    if score_recommended == 0
      result = 100
    else
      ratio = score/score_recommended
      result = (ratio*100).round
    end
  end

  # returns the color code corresponding to the ratio between actual value and target value
  def get_color_number_relative value
    color_number = 0
    color_number += 1 while (value > (COLOR_THRESHOLDS_RELATIVE[color_number]||0) and color_number < COLOR_THRESHOLDS_RELATIVE.size)
    color_number
  end

  # returns the color code corresponding to the difference between actual value and target value
  def get_color_number_absolute value
    color_number = 0
    color_number += 1 while (value >= (COLOR_THRESHOLDS_ABSOLUTE[color_number]||0) and color_number < COLOR_THRESHOLDS_ABSOLUTE.size)
    color_number
  end


  def get_score_or_zero p_infos, spec_id
    begin
      score = p_infos[:specification_values][spec_id][:sv_score].round
    rescue
      score = 0
    end
    score
  end

  def get_max_price
    begin
      max_offer = Offer.order("price").last
      max_offer.price.ceil
    rescue
      raise max_offer.inspect
    end
  end

  def get_min_price
    begin
      min_offer = Offer.order("price").first
      min_offer.price.ceil
    rescue
      raise min_offer.inspect
    end
  end

  def link_to_suggestion product
    if root_url == "http://www.choisirfacile.com/"
      link_to product_path(product.to_param), :target => "_blank", :onClick => "_gaq.push(['_trackEvent', 'results_clicks', 'suggestion', \'star-#{product.to_param}\']);" do
        yield
      end
    else
      link_to product_path(product.to_param), :target => "_blank" do
        yield
      end
    end
  end

  def link_to_toggle_star_details open_or_close, label_on_button
    if root_url == "http://www.choisirfacile.com/"
      link_to label_on_button, '#', :onClick => "_gaq.push(['_trackEvent', 'toggle_details_click', 'toggle_details', \'#{open_or_close}-star-details\']);"
    else
      link_to label_on_button, '#'
    end
  end

  def product_score_flavor_text product
    score_rounded = product.spenta_score.round
    if  score_rounded < 88
      t_safe :product_score_flavor_text_low
    elsif score_rounded >= 88 and score_rounded < 98
      t_safe :product_score_flavor_text_medium
    elsif score_rounded >= 98 and score_rounded <= 110
      t_safe :product_score_flavor_text_optimum
    elsif score_rounded > 110 and score_rounded <= 125
      t_safe :product_score_flavor_text_high
    else
      t_safe :product_score_flavor_text_performance
    end
  end

  def go_button product
    offer_count = product.offers.count
    if offer_count == 1
      t_safe :one_offer_button
    else
      (t_safe :several_offers_button_1) + " " + offer_count.to_s +  " " + (t_safe :several_offers_button_2)
    end
  end

end

