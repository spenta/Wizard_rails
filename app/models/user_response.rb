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

  attr_accessor :specification_needs_for_mobilities, :specification_needs_for_usages, :gammas, :sigmas, :user_response, :products_scored, :user_request, :good_deals


  def initialize
    #hash specification_id => {mobility_id => [U, alpha, beta]}
    @specification_needs_for_mobilities = {}

    #hash specification_id => {super_usage_id => [U, alpha, beta]}
    @specification_needs_for_usages = {}

    #empty hash for each spec
    Specification.all.each do |spec|
      @specification_needs_for_mobilities[spec.id]={}
      @specification_needs_for_usages[spec.id]={}
    end
    #hash {specification_id => sigma}
    @sigmas={}

    #array [[specification_id,gamma]]
    @gammas= {}

    #array of products_scored
    @products_scored=[]
    Product.all.each { |p| @products_scored << ProductScored.new(p)}

    @good_deals = []
  end

  def process_specification_needs!
    #selected usages without mobilities
    @selected_usages_choices = []
    @user_request.usage_choices.each do |uc|
      @selected_usages_choices << uc unless uc.usage.super_usage.name == 'Mobilite' || !uc.is_selected
    end
    SuperUsage.all.each do |su|
      #handling of mobilities
      if su.name == 'Mobilite'
        su.usages.each do |m|
          mobility_choice = @user_request.usage_choices.where(:usage_id => m.id).first
          unless mobility_choice.nil?
            m.requirements.each do |req|
              #needs should be the same as requirements.
              @specification_needs_for_mobilities[req.specification_id][m.id] = [req.target_score, req.weight, mobility_choice.weight_for_user]
            end
          end
        end
      #handling of usages
      else
        @selected_usage_choices_for_super_usage = []
        @selected_usages_choices.each do |selected_uc|
          @selected_usage_choices_for_super_usage << selected_uc if su.usages.include?(selected_uc.usage)
        end
        num_selections = @selected_usage_choices_for_super_usage.size

        Specification.all.each do |spec|
          if num_selections == 0
            @specification_needs_for_usages[spec.id][su.id] = [0, 0, 0]
          else
            target_score = 0
            weight = 0
            @selected_usage_choices_for_super_usage.each do |uc|
              req = uc.usage.requirements.where(:specification_id => spec.id).first
              #target_score need is the maximal value among target_score for each requirement
              target_score = req.target_score if req.target_score > target_score
              #weight need is the average among weights for each requirement
              weight += req.weight/num_selections
              @specification_needs_for_usages[spec.id][su.id] = [target_score, weight, uc.weight_for_user]
            end
          end
        end
      end
    end
  end

  def process_sigmas!
    Specification.all.each do |spec|
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
    @specification_needs_for_usages[Specification.first.id].each_value {|needs| sum_beta_usages += needs[2]}
    @specification_needs_for_mobilities[Specification.first.id].each_value {|needs| sum_beta_mobilities += needs[2]}
    Specification.all.each do |spec|
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
    @products_scored.each do |ps|
      product_id = ps.product.id
      specification_scores = ProductSpecScore.where(:product_id => product_id)
      specification_scores_hash = {}
      specification_scores.each {|ss| specification_scores_hash[ss.specification_id] = ss.score}
      Specification.all.each do |spec|
        #null scores replaced with 0
        score = specification_scores_hash[spec.id]
        sigma, gamma, tau = sigmas[spec.id], gammas[spec.id], score ? score : 0
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
    #products_scored is separated in two subgroups : recommended products and not recommended  products
    recommended_products = []
    not_recommended_products = []
    @products_scored.each {|ps| ps.delta <= delta_ok ? recommended_products << ps : not_recommended_products << ps}
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
    @products_scored.each { |p| products_with_good_scores << p }
    remaining_products = remove_low_scores_from products_with_good_scores
    #add the first products to good_deals and move the rest to remaining_products
    remaining_products = remaining_products | add_to_good_deals_from(products_with_good_scores)
    complete_good_deals_from remaining_products if @good_deals.size < N_BA
    restrict_good_deals if @good_deals.size > N_BA
    @products_scored.each {|p| p.is_good_deal = true if @good_deals.include? p}
  end

  def process_stars!
    products_with_perfect_score = []
    other_good_deals = []
    stars = []
    @good_deals.each { |p| p.spenta_score == S_R ? products_with_perfect_score << p : other_good_deals << p  }
    #put the product with score S_R with the best s/p in stars if any, otherwise the product with the highest Q
    sort_by_score_over_price products_with_perfect_score
    if products_with_perfect_score.empty?
      sort_by_Q other_good_deals
      stars << other_good_deals.last
    else
      stars << products_with_perfect_score.last
    end
    #then put the best performing product
    @good_deals.sort! {|p1,p2| p1.spenta_score <=> p2.spenta_score}
    complete stars, :with => @good_deals, :until_size_is => 2, :allowing_duplicate => false
    #then complete with good_deals with best s/p
    sort_by_score_over_price @good_deals
    complete stars, :with => @good_deals, :until_size_is => N_S, :allowing_duplicate => false
    #finally tag star products
    stars.each { |p| p.is_star = true }
  end

  def complete_good_deals_from remaining_products
    products_closest_to_good_deals = []
    other_products_close_to_good_deals = []
    @good_deals.each do |good_ps|
      #best distance to good_ps among remaining products
      best_distance = 10
      #best candidate among remaining_products
      best_candidate = nil
      remaining_products.each do |candidate_ps| #aka DSK
        distance = distance good_ps, candidate_ps
        if distance < 1
          other_products_close_to_good_deals << candidate_ps unless other_products_close_to_good_deals.include? candidate_ps
          best_candidate, best_distance = candidate_ps, distance if distance < best_distance
        end
      end
      #move the best candidate, if any, to new_good_deals
      unless best_candidate.nil? or products_closest_to_good_deals.include? best_candidate
        products_closest_to_good_deals << best_candidate
        other_products_close_to_good_deals.delete best_candidate
      end
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
    sort_by_Q other_products
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

  def build_user_response
    products_for_display = []
    @products_scored.each { |p| products_for_display << ProductForDisplay.new(p) }
    @user_response = UserResponse.new(gammas, sigmas, products_for_display)
  end
end

class UserResponse
  attr_accessor  :gammas, :sigmas, :products_for_display
  def initialize gammas, sigmas, products_for_display
    @gammas = gammas
    @sigmas = sigmas
    @products_for_display = products_for_display
  end

  #star_products plus some additionnal properties from related products in the database.
  def get_star_products_to_display
    star_products = products_for_display.select{|ps| ps.is_star}
    star_products_to_display = star_products.collect {|p| ProductToDisplay.new p}
  end

  #good_deal_products plus some additionnal properties from related products in the database.
  def get_good_deal_products_to_display
    good_deal_products = products_for_display.select{|ps| ps.is_good_deal and !ps.is_star}
    good_deal_products_to_display = good_deal_products.collect {|p| ProductToDisplay.new p}
  end
end

class ProductScored
  attr_accessor :delta, :pi, :spenta_score, :product, :is_good_deal, :is_star, :price
  def initialize product
    @product = product
    @delta, @pi, @is_good_deal, @is_star = 0, 0, false, false
    @price = @product.price
  end
end

#similar to ProductScored, only with a @product_id attribute instead of a
#@product attribute to facilitate serialization, and no delta and pi
class ProductForDisplay
  attr_accessor :spenta_score, :product_id, :is_good_deal, :is_star, :price
  def initialize product_scored
    @product_id = product_scored.product.id
    @price = product_scored.price
    @spenta_score = product_scored.spenta_score
    @is_good_deal = product_scored.is_good_deal
    @is_star = product_scored.is_star
  end
end
#similar to ProductForDisplay, but with attributes from related product with were to big to be serialized
class ProductToDisplay < ProductForDisplay
attr_accessor :small_img_url, :big_img_url, :brand_name, :name, :product_id, :price, :spenta_score, :is_good_deal, :is_star, :specification_values
  def initialize product_for_display
    @product_id = product_for_display.product_id
    @price = product_for_display.price
    @spenta_score = product_for_display.spenta_score
    @is_good_deal = product_for_display.is_good_deal
    @is_star = product_for_display.is_star
    product = Product.find(@product_id)
    @small_img_url = product.small_img_url
    @big_img_url = product.big_img_url
    @brand_name = Brand.find(product.brand_id).name
    @name = product.name
    @specification_values = build_specification_values
  end

  # returns a hash representing the product's specs value
  # ex: specification_values = p1.specification_values
  # specification_values #=> {1 => {:name => Core i7, :scorer => 8.3}}
  def build_specification_values
    specs_values = {}
    product_specification_values = ProductsSpecsValue.where(:product_id => @product_id).where("specification_value_id > 0")
    product_specification_values_hash = {}
    product_specification_values.each {|psv| product_specification_values_hash[psv.specification_id] = SpecificationValue.find(psv.specification_value_id)}
    Specification.where(:specification_type => ["continuous", "discrete"]).each do |spec|
      spec_id = spec.id
      specification_value = product_specification_values_hash[spec_id]
      spec_value_name_and_score={}
      spec_value_name_and_score[:name] = specification_value.name
      spec_value_name_and_score[:score] = specification_value.score
      specs_values[spec_id] = spec_value_name_and_score 
    end
    specs_values
  end
end