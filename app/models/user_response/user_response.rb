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
  end

  def get_response
    @builder.user_response ? @builder.user_response : @builder.build_user_response
  end
end

#laptop-wizard-specific
class UserResponseBuilder
  attr_accessor :specification_needs_for_mobilities, :specification_needs_for_usages, :gammas, :sigmas, :user_response, :products_scored, :user_request, :good_deals

  #parameters are defined here instead of a config file because they heavily depend on the implementation.
  AFU = 0.5
  RWU = 40
  AFM = 0.25
  RWM = 100
  R = 350
  GAP_MAX = 6
  ZETA = 1
  NU = 1.5
  LAMBDA = 0.5
  GAP_TOL = 0.2
  S_R = 100
  KAPPA = 40
  C_P = 50
  C_S = 5
  S_MIN = 70
  N_MIN = 4

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

    #hash {specification_id => gamma}
    @gammas={}

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
      #create a hash specification_id => specification_value for serious performance reasons
      specification_values_hash={}
      ps.product.specification_values.each do |sv|
        specification_values_hash[sv.specification_id]=sv
      end
      Specification.all.each do |spec|
        specification_value = specification_values_hash[spec.id]
        #null scores replaced with 0
        sigma, gamma, tau = sigmas[spec.id], gammas[spec.id], specification_value ? specification_value.score : 0
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
      recommended_products = recommended_products.sort {|p1, p2| p1.pi <=> p2.pi}
      pi_min = recommended_products.first.pi
      recommended_products.each { |ps| ps.spenta_score = S_R + KAPPA * (ps.pi - pi_min)/sum_gamma }
    end
    #scores for not_recommended_products
    # s = a.delta + b for each product_scored
    a = - S_R/(sum_gamma*(GAP_MAX-GAP_TOL))
    b = S_R * GAP_MAX/(GAP_MAX - GAP_TOL)
    not_recommended_products.each { |ps| ps.spenta_score = a*ps.delta + b}
  end

  def process_good_deals_old!
    #array containing good_deals (P+)
    good_deals = []
    #products_scored sorted by increasing price
    @products_scored = sort_by_price @products_scored
    good_deals << @products_scored.first
    #-----------------
    #  first step : we keep products that may be ordered by increasing price and score
    #-----------------
    #the first element of products_scored is removed and added back at the end in order not to mess the loop
    first_product = @products_scored.slice! 0
    @products_scored.each do |current_ps|
      last_ps = good_deals.last
      if (current_ps.price == last_ps.price and current_ps.spenta_score == last_ps.spenta_score) or (current_ps.price > last_ps.price and current_ps.spenta_score > last_ps.spenta_score)
        good_deals << current_ps
      elsif current_ps.price == last_ps.price and current_ps.spenta_score > last_ps.spenta_score
        good_deals << current_ps
        good_deals.delete last_ps
      end
    end
    #set is_good_deal to true for each member of good_deals
    good_deals.each { |ps| ps.is_good_deal = true }
    #put the first element back
    @products_scored << first_product
    #create products_scored\good_deals (P-)
    remaining_products = []
    @products_scored.each { |ps| remaining_products << ps unless ps.is_good_deal }
    #P- and P+ are sorted by increasing price
    remaining_products = sort_by_price remaining_products
    good_deals = sort_by_price good_deals
    #-----------------
    #  second step : tolerance
    #-----------------
    new_good_deals = []
    good_deals.each do |good_ps|
      #best distance to good_ps among remaining products
      best_distance = 10
      #best candidate among remaining_products
      best_candidate = nil
      remaining_products.each do |candidate_ps| #aka DSK
        distance = distance good_ps, candidate_ps
        if distance < 1 and distance < best_distance
          best_candidate, best_distance = candidate_ps, distance
        end
      end
      #move the best candidate, if any, from remaining_products to new_good_deals
      unless best_candidate.nil?
        new_good_deals << best_candidate
        remaining_products.delete best_candidate
      end
    end
    #-----------------
    #  third step : filtering by spenta_score
    #-----------------
    good_deals.each { |ps| good_deals.delete ps if ps.spenta_score < S_MIN}
    #-----------------
    #  fourth step : adding products_scored with spenta_score > S_MIN
    #-----------------
    #if need be, remaining_products are ordered by decreasing spenta_score/price
    if good_deals.size < N_MIN
      remaining_products.sort {|p2, p1| p1.spenta_score/p1.price <=> p2.spenta_score/p2.price}
      remaining_products.each do |best_remaining_product|
        if good_deals.size < N_MIN and best_remaining_product.spenta_score > S_MIN
          good_deals << best_remaining_product
          remaining_products.delete best_remaining_product
        end
      end
    end

    #-----------------
    #  fifth step : adding products_scored with best spenta_score
    #-----------------
    #if need be, remaining_products are ordered by decreasing spenta_score
    if good_deals.size < N_MIN
      remaining_products.sort {|p2, p1| p1.spenta_score <=> p2.spenta_score}
      remaining_products.each do |ps|
        if good_deals.size < N_MIN
          good_deals << ps
          remaining_products.delete ps
        end
      end
    end

    #-----------------
    #  sixth step : flagging good_deals products
    #-----------------
    good_deals.each { |ps| ps.is_good_deal = true }
  end

  def process_good_deals!
    #good score means >= S_MIN
    products_with_good_scores = []
    @products_scored.each { |p| products_with_good_scores << p }
    remaining_products = remove_low_scores_from products_with_good_scores
  end

  def sort_by_price ary
    ary.sort! {|p1, p2| p1.price <=> p2.price}
  end

  def distance p1, p2
    price_spread = (p1.price - p2.price)/C_P
    score_spread = (p1.spenta_score - p2.spenta_score)/C_S
    d = Math.sqrt(price_spread**2+score_spread**2)
  end

  #returns removed products
  def remove_low_scores_from products
    products_with_low_scores = []
    products.each do |p|
      if p.spenta_score < S_MIN
        products_with_low_scores << p
        products.delete p
      end
    end
    products_with_low_scores
  end

  #returns the products which where not added to good_deals
  def add_to_good_deals_from products
    remaining_products = []
    sort_by_price products
    products.each do |current_ps|
      # TEMP *********************
      puts "current product id : #{current_ps.product.id}"
      if @good_deals.empty?
        # TEMP *********************
        puts "no element in good deals"
        # TEMP *********************
        puts "----------------------"
        @good_deals << current_ps
      else
        last_ps = @good_deals.last
        #if the current product is as good as and as cheap as the previous one, or if it is
        #more expensive, but better, then put it in good_deals
        if (current_ps.price == last_ps.price and current_ps.spenta_score == last_ps.spenta_score) or (current_ps.price > last_ps.price and current_ps.spenta_score > last_ps.spenta_score)
          # TEMP *********************
          puts "first case"
          # TEMP *********************
          puts "----------------------"
          @good_deals << current_ps
        #if the current product is as cheap as the previous one but better,
        #add it to good_deals and remove the previous one
        elsif current_ps.price == last_ps.price and current_ps.spenta_score > last_ps.spenta_score
          # TEMP *********************
          puts "second case"
          # TEMP *********************
          puts "----------------------"
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

  def build_user_response
    @user_response = UserResponse.new(gammas, sigmas, products_scored)
  end
end

class UserResponse
  attr_accessor  :gammas, :sigmas, :products_scored
  def initialize gammas, sigmas, products_scored
    @gammas = gammas
    @sigmas = sigmas
    @products_scored = products_scored
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

