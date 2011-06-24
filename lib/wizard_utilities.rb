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

  def sort_by_price ary
    ary.sort! {|p1, p2| p1.price <=> p2.price}
  end

  def sort_by_spenta_score ary
    ary.sort! {|p1, p2| p1.spenta_score <=> p2.spenta_score}
  end

  def sort_by_score_over_price ary
    ary.sort! {|p1, p2| score_over_price(p1) <=> score_over_price(p2)}
  end

  def sort_by_Q ary
    ary.sort! {|p1, p2| quality_score(p1) <=> quality_score(p2)}
  end

  def quality_score product
    product.spenta_score >= S_R ? exp_factor = EXP_FACTOR_SUP : exp_factor = EXP_FACTOR_INF
    spread_factor = Math.exp(-((product.spenta_score-S_R)**2/(exp_factor*S_R**2)))
    score = spread_factor * score_over_price(product)
  end

  def get_highest_energy_pair products
    highest_energy = 0
    highest_energy_pair = [products[0], products[1]]
    for i in [0..products.length-2]
      p1 = products[0]
      p2 = products[1]
      energy = get_energy p1, p2, products
      #TEMP
      highest_energy_name = gets_highest_energy_name p1, p2, products
      if energy > highest_energy
        highest_energy = energy
        highest_energy_pair = [p1, p2]
      end
    end
    #TEMP
    puts highest_energy_name
    highest_energy_pair
  end

  def get_energy p1, p2, products
    1000*energy_bad_score(p1, p2)+100*energy_better_deal(p1, p2)+10*energy_brand(p1, p2, products)+energy_similar(p1, p2)
  end

  #TEMP
  def gets_highest_energy_name p1, p2, products
    energies= {
      "bad_score" => 1000*energy_bad_score(p1, p2),
      "better_deal" => 100*energy_better_deal(p1, p2),
      "brand" => 10*energy_brand(p1, p2, products),
      "similar" => energy_similar(p1, p2)
    }
    highest_energy_name = "none"
    highest_energy_value = 0
    energies.each do |key, value| 
      if value > highest_energy_value
        highest_energy_name = key
        highest_energy_value = value
      end
    end
    highest_energy_name
  end

  def energy_bad_score p1, p2
    a = ENERGY_BAD_SCORE_MODIFICATOR
    b = ENERGY_BAD_SCORE_FACTOR
    b*Math.exp(-(p1.spenta_score+p2.spenta_score)/(a*S_R))
  end

  def energy_better_deal p1, p2
    ENERGY_BETTER_DEAL_FACTOR*delta_score_over_price(p1,p2)/average_score_over_price(p1,p2)
  end

  def energy_brand p1, p2, products
    a = ENERGY_BRAND_MODIFICATOR
    b = ENERGY_BRAND_FACTOR
    num_brand1 = num_products_with_same_brand p1, products
    num_brand2 = num_products_with_same_brand p2, products
    b * (1-Math.exp(-a*(num_brand1+num_brand2-2)**3))
  end

  def energy_similar p1,p2
    s1 = p1.spenta_score
    s2 = p2.spenta_score
    p1 = p1.price
    p2 = p2.price
    get_relative_spread(s1, s2) + get_relative_spread(p1, p2)
  end

  def delta_score_over_price p1, p2
    (score_over_price(p1)-score_over_price(p2)).abs
  end
  
  def average_score_over_price p1, p2
    (score_over_price(p1)+score_over_price(p2))/2
  end

  def score_over_price product
    product.spenta_score/product.price
  end

  def num_products_with_same_brand product_for_calculations, products
    brand = product_for_calculations.product.infos[:brand_name]
    num = 0
    products.each {|p| num += 1 if p.product.infos[:brand_name] == brand}
    num
  end
  
  def get_relative_spread num1, num2
    1/(1+(num1-num2).abs/(num1+num2))
  end

  def worst_product p1, p2, products
    if quality_score_with_brand_penalty(p1, products) <= quality_score_with_brand_penalty(p2, products)
      p1
    else
      p2
    end
  end

  def quality_score_with_brand_penalty product, products
    a = BRAND_PENALTY
    quality_score(product)*Math.exp(-a*(num_products_with_same_brand(product, products)**3))
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
end
