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

  # A product is said to have a low performance (L) if score < 90
  # A product is said to have a medium performance (M) if 90 <= score < 110
  # A product is said to have a high performance (H) if 110 < score
  def category_of product
    if product.spenta_score < 90
      "L"
    elsif product.spenta_score > 110
      "H"
    else
      "M"
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


  def cat_subtitle
    str = "#{t :cat_subtitle_1 } <strong>#{Product.all_cached.size} #{t :cat_subtitle_2 }</strong> #{t :cat_subtitle_3} <strong>#{Retailer.count} #{t :cat_subtitle_4}</strong> #{t :cat_subtitle_5}"
    str.html_safe
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
end
