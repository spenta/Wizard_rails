module WizardUtilities
  include WizardParameters

  #builds an array of U* from specification_needs. The third argument tells wether the needs refers to usages or mobilities
  def specification_needs_to_u_star specification_needs, spec, usages_or_mobilities
    u_star_for_spec = []
    specification_needs[spec.id].each_value do |needs_for_spec|
        u_star_for_spec << get_modified_target_score(needs_for_spec, usages_or_mobilities, spec.specification_type)
    end
    u_star_for_spec
  end

  def get_modified_target_score needs_for_spec, usages_or_mobilities, specification_type
    case usages_or_mobilities
      when 'usages' then af, rw = AFU, RWU
      when 'mobilities' then af, rw = AFM, RWM
    end

    case specification_type
      when 'continuous' then result = needs_for_spec[0] * [1, (1-af)*needs_for_spec[2]/rw +af].min
      when 'discrete' then result = needs_for_spec[0]
      when 'not_marked' then result = 0
    end
  end

  def distance p1, p2
    price_spread = (p1.price - p2.price)/C_P
    score_spread = (p1.spenta_score - p2.spenta_score)/C_S
    d = Math.sqrt(price_spread**2+score_spread**2)
  end

  def sort_by_price ary
    ary.sort! {|p1, p2| p1.price <=> p2.price}
  end

  def sort_by_spenta_score ary
    ary.sort! {|p1, p2| p1.spenta_score <=> p2.spenta_score}
  end

  def sort_by_score_over_price ary
    ary.sort! {|p1, p2| p1.spenta_score/p1.price <=> p2.spenta_score/p2.price}
  end

  def sort_by_q ary
    ary.sort! {|p1, p2| quality_score(p1) <=> quality_score(p2)}
  end

  def sort_by_q_with_brand_penalty ary
    ary.sort! {|p1, p2| quality_score_with_brand_penalty(p1) <=> quality_score_with_brand_penalty(p2)}
  end

  def quality_score product
    product.spenta_score >= S_R ? exp_factor = EXP_FACTOR_SUP : exp_factor = EXP_FACTOR_INF
    spread_factor = Math.exp(-((product.spenta_score-S_R)**2/(exp_factor*S_R**2)))
    score_price_ratio_factor = product.spenta_score/product.price
    score = spread_factor * score_price_ratio_factor
  end

  #completes an array with another by beginning from last position
  #ex: complete good_deals, :with => remaining_products, :until_size_is => 10, :allowing_duplicate => false, :and_delete_from_source => true
  # => true if ary.size == :until_size_is
  # => :not_enough_elements if ary.size < :until_size_is
  def complete(ary, params={:and_delete_from_source => false, :allowing_duplicate => true})
    ary_to_add = []
    params[:with].each { |p| ary_to_add << p }
    ary_to_add_size = ary_to_add.size
    until (ary.size >= params[:until_size_is] or ary_to_add.empty?)
      current_item = ary_to_add.last
      unless (:allowing_duplicate and ary.include?(current_item))
        ary << current_item
        params[:with].delete current_item if params[:and_delete_from_source]
      end
      ary_to_add.pop
    end
  end

  #returns removed products
  def remove_low_scores_from products
    products_with_low_scores = []
    products.each do |p|
      if p.spenta_score < S_MIN
        products_with_low_scores << p
      end
    end
    products_with_low_scores.each {|p| products.delete p}
  end

  def num_products_with_same_brand product_for_calculations, products
    #raise product_for_calculations.inspect
    brand = product_for_calculations.product.infos[:brand_name]
    num = 0
    products.each {|p| num += 1 if p.product.infos[:brand_name] == brand}
    num
  end

  def quality_score_with_brand_penalty product, products
    quality_score(product)*brand_penalty(product, products)
  end

  def brand_penalty product, products
    a = BRAND_PENALTY
    Math.exp(-a*(num_products_with_same_brand(product, products)**3))
  end

  def get_similar_products product, products, options={:with_brand_penalty => nil}
    result={}
    result[:best_candidate] = nil
    result[:other_close_products] = []
    #best distance to products among products
    best_distance = 10
    brand_factor = options[:with_brand_penalty].nil? ? 1 : brand_penalty(product, options[:with_brand_penalty])
    products.select{|p| p != product}.each do |candidate_product|
      distance = brand_factor*distance(product, candidate_product)
      if distance < 1
        result[:other_close_products] << candidate_product
        result[:best_candidate], best_distance = candidate_product, distance if distance < best_distance
      end
    end
    result[:other_close_products].delete result[:best_candidate]
    result
  end
end
