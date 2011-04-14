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
  end

  def get_response
    @builder.user_response ? @builder.user_response : @builder.build_user_response
  end
end

#laptop-wizard-specific
class UserResponseBuilder
  attr_accessor :specification_needs_for_mobilities, :specification_needs_for_usages, :gammas, :sigmas, :user_response, :products_scored, :user_request

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
  attr_accessor :delta, :pi, :spenta_score, :product
  def initialize product
    @product = product
    @delta, @pi = 0,0
  end
end

