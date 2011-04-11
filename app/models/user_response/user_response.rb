class UserResponseDirector
  attr_accessor :builder

  def get_response
    @builder.user_response
  end

end

#laptop-wizard-specific
class UserResponseBuilder
  attr_accessor :user_response

  def initialize
    @user_response = UserResponse.new

    #hash specification_id => {mobility_id => [U, alpha, beta]}
    @user_response.specification_needs_for_mobilities = {}

    #hash specification_id => {super_usage_id => [U, alpha, beta]}
    @user_response.specification_needs_for_usages = {}

    #empty hash for each spec
    Specification.all.each do |spec|
      @user_response.specification_needs_for_mobilities[spec.id]={}
      @user_response.specification_needs_for_usages[spec.id]={}
    end

  end

  def process_specification_needs! usage_choices
    #selected usages without mobilities
    @selected_usages_choices = []
    usage_choices.each do |uc|
      @selected_usages_choices << uc unless uc.usage.super_usage.name == 'Mobilite' || !uc.is_selected
    end
    SuperUsage.all.each do |su|
      #handling of mobilities
      if su.name == 'Mobilite'
        su.usages.each do |m|
          mobility_choice = usage_choices.where(:usage_id => m.id).first
          unless mobility_choice.nil?
            m.requirements.each do |req|
              @user_response.specification_needs_for_mobilities[req.specification_id][m.id] = [req.target_score, req.weight, mobility_choice.weight_for_user]
            end
          end
        end
      #handling of usages
      else;
        @selected_usage_choices_for_super_usage = []

        @selected_usages_choices.each do |selected_uc|
          @selected_usage_choices_for_super_usage << selected_uc if su.usages.include?(selected_uc.usage)
        end
        num_selections = @selected_usage_choices_for_super_usage.size

        Specification.all.each do |spec|
          if num_selections == 0
            @user_response.specification_needs_for_usages[spec.id][su.id] = [0, 0, 0]
          else
            target_score = 0
            weight = 0
            @selected_usage_choices_for_super_usage.each do |uc|
              req = uc.usage.requirements.where(:specification_id => spec.id).first
              target_score = req.target_score if req.target_score > target_score
              weight += req.weight/num_selections
              @user_response.specification_needs_for_usages[spec.id][su.id] = [target_score, weight, uc.weight_for_user]
            end
          end
        end
      end
    end
  end

end

class UserResponse
  attr_accessor :specification_needs_for_mobilities, :specification_needs_for_usages, :products_scored
end

class ProductScored
  attr_accessor :spenta_score, :product
end

class ProcessedUsageChoice
  def initialize weight_for_user, usage
    @weight_for_user = weight_for_user
    @usage = usage
  end
  attr_accessor :weight_for_user, :usage
end

