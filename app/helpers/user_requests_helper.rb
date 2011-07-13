module UserRequestsHelper
  include WizardUtilities

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

end

