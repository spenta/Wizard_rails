class UserRequest < ActiveRecord::Base
  has_many :usage_choices, :dependent => :destroy


  def update! params
    @super_usage_choices = {}
    @usage_choices_selected=[]
    params.keys.each do |param_key|
      #update of weight for usage_choices except for mobilities
      if param_key =~ /super_usage_choice_./
        @super_usage_to_update_id = param_key.split('_').last
        @usages_to_update_id = SuperUsage.find(@super_usage_to_update_id).usages
        @usage_choices_to_update = usage_choices.where(:usage_id => @usages_to_update_id)
        @usage_choices_to_update.each do |uc|
          raise "invalid number given for usage #{uc.usage.name}" unless uc.update_attributes :weight_for_user => params[param_key]
        end
      #list of usage_choices to be selected
      elsif param_key =~ /usage_choice_selected_./
        @usage_choices_selected << Integer(param_key.split('_').last)
      #update of weight for mobilities
      elsif param_key =~ /mobility_choice_./
        @mobility_choice_to_update = UsageChoice.find(param_key.split('_').last)
        raise "invalid number given for usage #{@mobility_choice_to_update.usage.name}" unless @mobility_choice_to_update.update_attributes :weight_for_user => params[param_key]
      end
    end
    raise "invalid response parameters given" unless update_attributes(params[:user_request])
    #update of is_selected for each usage_choice
    usage_choices.each do |uc|
      unless uc.usage.super_usage.name == "Mobilite"
        uc.update_attributes :is_selected => @usage_choices_selected.include?(uc.id)
      end
    end
    raise "Veuillez choisir au moins un usage !" if @usage_choices_selected.empty?
  end
end

