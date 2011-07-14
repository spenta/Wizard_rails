#We use a builder pattern to create a user_response. see the algo doc for the notations.
class UserResponseDirector
  attr_accessor :builder
  def init_builder user_request
    @builder = UserResponseBuilder.new if @builder.nil?
    @builder.user_request = user_request
  end

  def process_response
    @builder.process_specification_needs!
    @builder.process_sigmas!
    @builder.process_gammas!
    @builder.process_pi_and_delta!
    @builder.process_scores!
    @builder.process_good_deals!
    @builder.process_stars!
  end

  def get_response
    @builder.user_response ? @builder.user_response : @builder.build_user_response
  end

  def clear!
    @builder = nil
  end
end

#laptop-wizard-specific
class UserResponseBuilder
  include WizardParameters
  include WizardUtilities

  attr_accessor :specification_needs_for_mobilities, :specification_needs_for_usages, :gammas, :sigmas, :user_response, :products_for_calculations, :user_request, :good_dealsCO


  def initialize
    #hash specification_id => {mobility_id => [U, alpha, beta]}
    @specification_needs_for_mobilities = {}

    #hash specification_id => {super_usage_id => [U, alpha, beta]}
    @specification_needs_for_usages = {}

    #empty hash for each spec
    Specification.all_cached.each do |spec|
      @specification_needs_for_mobilities[spec.id]={}
      @specification_needs_for_usages[spec.id]={}
    end
    #hash {specification_id => sigma}
    @sigmas={}

    #array [[specification_id,gamma]]
    @gammas= {}

    #array of products_for_calculations
    @products_for_calculations=[]
    Product.all_cached.each { |p| @products_for_calculations << ProductForCalculations.new(p)}

    @good_deals = []
  end

  def process_specification_needs!
    #selected usages without mobilities
    @selected_usage_choices = []
    mobility_ids = SuperUsage.mobilities
    @user_request.usage_choices.each do |uc|
      @selected_usage_choices << uc unless mobility_ids.include?(uc.usage_id) == 'Mobilite' || !uc.is_selected
    end
    #handling of mobilities
    mobility_ids.each do |mobility_id|
      mobility_choice = @user_request.usage_choices.select{|uc| uc.usage_id == mobility_id}.first
      unless mobility_choice.nil?
        Requirement.mobilities_requirements[mobility_id].each do |spec_id, req_hash|
          #needs should be the same as requirements.
          @specification_needs_for_mobilities[spec_id][mobility_id] = [req_hash[:target_score], req_hash[:weight], mobility_choice.weight_for_user]
        end
      end
    end
    #handling of usages
    SuperUsage.all_cached_no_mobilities.each do |su_id, u_ids|
      @selected_usage_choices_for_super_usage = @selected_usage_choices.select{|uc| u_ids.include?(uc.usage_id)}
      num_selections = @selected_usage_choices_for_super_usage.size

      Specification.all_cached.each do |spec|
        if num_selections == 0
          @specification_needs_for_usages[spec.id][su_id] = [0, 0, 0]
        else
          target_score = 0
          weight = 0
          @selected_usage_choices_for_super_usage.each do |uc|
            usage_id = uc.usage_id
            req_hash = Requirement.usages_requirements[usage_id][spec.id]
            #target_score need is the maximal value among target_score for each requirement
            target_score = req_hash[:target_score] if req_hash[:target_score] > target_score
            #weight need is the average among weights for each requirement
            weight += req_hash[:weight]/num_selections
            @specification_needs_for_usages[spec.id][su_id] = [target_score, weight, uc.weight_for_user]
          end
        end
      end
    end
  end

  def process_sigmas!
    Specification.all_cached.each do |spec|
      #modified target scores for spec. for usages
      u_star_for_spec = specification_needs_to_u_star @specification_needs_for_usages, spec, 'usages'

      #modified target scores for spec. for mobilities
      u_prime_star_for_spec = specification_needs_to_u_star @specification_needs_for_mobilities, spec, 'mobilities'

      #sigma is the maximal value among U* for each spec
      @sigmas[spec.id]=(u_star_for_spec | u_prime_star_for_spec).max
    end
  end

  def process_gammas!
    #calculate sum_beta_usages et sum_beta_mobilities
    sum_beta_usages, sum_beta_mobilities = 0,0
    @specification_needs_for_usages[Specification.all_cached.first.id].each_value {|needs| sum_beta_usages += needs[2]}
    @specification_needs_for_mobilities[Specification.all_cached.first.id].each_value {|needs| sum_beta_mobilities += needs[2]}
    Specification.all_cached.each do |spec|
      #gammas for usages
      theta, theta_prime = 0,0
      #calculate theta
      unless sum_beta_usages == 0
        @specification_needs_for_usages[spec.id].each_value {|needs| theta += needs[1]*needs[2]}
        theta *= R/sum_beta_usages
      end
      #calculate theta_prime
      @specification_needs_for_mobilities[spec.id].each_value {|needs| theta_prime += needs[1]*needs[2]}
      #calculate gamma
      @gammas[spec.id] = (theta + theta_prime)/(R+sum_beta_mobilities)
    end
  end

  def process_pi_and_delta!
    @products_for_calculations.each do |ps|
      product = ps.product
      product_id = product.id
      Specification.all_cached.collect{|spec| spec.id}.each do |spec_id|
        #null scores replaced with 0
        begin
          score = product.infos[:specification_values][spec_id][:sv_score]
        rescue
          score = 0
        end
        sigma, gamma, tau = sigmas[spec_id], gammas[spec_id], score ? score : 0
        #delta
        ps.delta += gamma*([GAP_MAX, ZETA*(([0,(sigma-tau)/ZETA].max)**NU)]).min
        #pi
        ps.pi +=gamma*((tau-sigma)<=>0)*Math.log(1+LAMBDA*(tau-sigma).abs)/LAMBDA
      end
    end
  end

  def process_scores!
    #delta_ok
    sum_gamma = 0
    @gammas.each_value { |gamma| sum_gamma+=gamma }
    delta_ok = sum_gamma * GAP_TOL
    #products_for_calculations is separated in two subgroups : recommended products and not recommended  products
    recommended_products = []
    not_recommended_products = []
    @products_for_calculations.each {|ps| ps.delta <= delta_ok ? recommended_products << ps : not_recommended_products << ps}
    #scores for recommended_products
    unless recommended_products.empty?
      #recommended_products is sorted by increasing pi
      recommended_products.sort! {|p1, p2| p1.pi <=> p2.pi}
      pi_min = recommended_products.first.pi
      recommended_products.each { |ps| ps.spenta_score = S_R + KAPPA * (ps.pi - pi_min)/sum_gamma }
    end
    #scores for not_recommended_products
    # s = a.delta + b for each product_scored
    a = - S_R/(sum_gamma*(GAP_MAX-GAP_TOL))
    b = S_R * GAP_MAX/(GAP_MAX - GAP_TOL)
    not_recommended_products.each { |ps| ps.spenta_score = a*ps.delta + b}
  end

  def process_good_deals!
    #good score means >= S_MIN
    products_with_good_scores = []
    @products_for_calculations.each { |p| products_with_good_scores << p }
    remaining_products = remove_low_scores_from products_with_good_scores
    #add the first products to good_deals and move the rest to remaining_products
    remaining_products = remaining_products | add_to_good_deals_from(products_with_good_scores)
    if @good_deals.empty?
      @good_deals = sort_by_q(@products_for_calculations).last(3)
      @good_deals.each{|p| remaining_products.delete p}
    end
    complete_good_deals_from remaining_products if @good_deals.size < N_BA
    restrict_good_deals if @good_deals.size > N_BA
    substitute_with_other_brands @good_deals, @products_for_calculations
    @products_for_calculations.each {|p| p.is_good_deal = true if @good_deals.include? p}
  end

  def process_stars!
    stars = (sort_by_q(@good_deals)).last(N_S)
    #finally tag star products
    stars.each { |p| p.is_star = true }
  end

  def complete_good_deals_from remaining_products
    products_closest_to_good_deals = []
    other_products_close_to_good_deals = []
    @good_deals.each do |good_ps|
      similar_products = get_similar_products good_ps, remaining_products
      best_candidate = similar_products[:best_candidate]
      other_close_products = similar_products[:other_close_products]
      #move the best candidate, if any, to new_good_deals
      unless best_candidate.nil? or products_closest_to_good_deals.include? best_candidate
        products_closest_to_good_deals << best_candidate
      end
      other_products_close_to_good_deals = other_products_close_to_good_deals | other_close_products
    end
    other_products_close_to_good_deals.each {|p| remaining_products.delete other_products_close_to_good_deals}
    #complete good_deals with products_closest_to_good_deals, by s/p descending
    sort_by_score_over_price products_closest_to_good_deals
    complete @good_deals, :with => products_closest_to_good_deals, :until_size_is => N_BA, :and_delete_from_source => false
    #complete good_deals with other_products_close_to_good_deals, by s/p descending
    sort_by_score_over_price other_products_close_to_good_deals
    complete @good_deals, :with => other_products_close_to_good_deals, :until_size_is => N_BA, :and_delete_from_source => false if @good_deals.size < N_BA
    #complete with remaining_products of good score by s/p descending
    if @good_deals.size < N_BA
      low_scores = remove_low_scores_from remaining_products
      sort_by_score_over_price remaining_products
      complete @good_deals, :with => remaining_products, :until_size_is => N_BA, :and_delete_from_source => false
    end
    #complete with low_scores b score desc
    if @good_deals.size < N_BA
      low_scores.sort! {|p1, p2| p1.spenta_score <=> p2.spenta_score}
      complete @good_deals, :with => low_scores, :until_size_is => N_BA, :and_delete_from_source => false
    end
  end


  def restrict_good_deals
    #products with spenta_score = S_R
    products_with_perfect_score = []
    other_products = []
    @good_deals.each {|p| p.spenta_score == S_R ? products_with_perfect_score << p : other_products << p}
    #sort other_products by descending Q
    sort_by_q other_products
    other_products.reverse!
    #products with the least spenta_scores are removed
    until (@good_deals.size <=N_BA or other_products.empty?)
      @good_deals.delete other_products.last
      other_products.pop
    end
    #sort products_with_perfect_score by ascending price
    sort_by_price products_with_perfect_score
    #the most expensive products with perfect scores are removed
    until (@good_deals.size <=N_BA or products_with_perfect_score.empty?)
      @good_deals.delete products_with_perfect_score.last
      products_with_perfect_score.pop
    end
  end

  #returns the products which where not added to good_deals
  def add_to_good_deals_from products
    remaining_products = []
    sort_by_price products
    products.each do |current_ps|
      if @good_deals.empty?
        @good_deals << current_ps
      else
        last_ps = @good_deals.last
        #if the current product is as good as and as cheap as the previous one, or if it is
        #more expensive, but better, then put it in good_deals
        if (current_ps.price == last_ps.price and current_ps.spenta_score == last_ps.spenta_score) or (current_ps.price > last_ps.price and current_ps.spenta_score > last_ps.spenta_score)
          @good_deals << current_ps
        #if the current product is as cheap as the previous one but better,
        #add it to good_deals and remove the previous one
        elsif current_ps.price == last_ps.price and current_ps.spenta_score > last_ps.spenta_score
          @good_deals.delete last_ps
          remaining_products << last_ps
          @good_deals << current_ps
        else
          remaining_products << current_ps
        end
      end
    end
    remaining_products
  end

  def substitute_with_other_brands products_to_substitute, candidate_products
    sort_by_q products_to_substitute
    candidate_products_not_products_to_substitute = candidate_products.select{|p| !products_to_substitute.include?(p)}
    for i in 0..products_to_substitute.length-1
      p = products_to_substitute[i]
      if num_products_with_same_brand(p, products_to_substitute) > THRESHOLD_NUM_PRODUCTS_WITH_SAME_BRAND
        best_candidate = get_similar_products(p, candidate_products_not_products_to_substitute, :with_brand_penalty => products_to_substitute )[:best_candidate]
        if best_candidate
          products_to_substitute[i] = best_candidate
          candidate_products_not_products_to_substitute.delete best_candidate
        end
      end
    end
  end

  def build_user_response
    products_scored = products_for_calculations.collect{|p| ProductScored.new(p.product.id, p.spenta_score, p.is_good_deal, p.is_star, p.price)}
    @user_response = UserResponse.new(gammas, sigmas, products_scored)
  end
end

class UserResponse
  include WizardUtilities
  attr_accessor  :gammas, :sigmas, :products_scored
  def initialize gammas, sigmas, products_scored
    @gammas = gammas
    @sigmas = sigmas
    @products_scored = products_scored
  end

  def get_star_products
    sort_by_spenta_score(@products_scored.select{|p| p.is_star})
  end

  def get_good_deal_products
    #sort_by_spenta_score(@products_scored.select{|p| p.is_good_deal and !p.is_star})
    sort_by_spenta_score(@products_scored.select{|p| p.is_good_deal})
  end
  
  def get_best_mac
    sort_by_q(@products_scored.select{|p| Rails.cache.read("product_infos_#{p.product_id}")[:brand_name] == "Apple"}).last
  end
end

class ProductForCalculations
  attr_accessor :delta, :pi, :spenta_score, :product, :is_good_deal, :is_star, :price
  def initialize product
    @product = product
    @delta, @pi, @is_good_deal, @is_star = 0, 0, false, false
    @price = @product.price
  end
end

class ProductScored
  attr_accessor :product_id, :spenta_score, :is_good_deal, :is_star, :price
  def initialize product_id, spenta_score, is_good_deal, is_star, price
    @product_id = product_id
    @spenta_score = spenta_score
    @is_good_deal = is_good_deal
    @is_star = is_star
    @price = price
  end
end
