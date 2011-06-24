class UserRequest < ActiveRecord::Base
  attr_writer :current_step
  has_many :usage_choices, :dependent => :destroy

  def current_step
    @current_step || steps.first
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  
  # Multi-step form done in the same way as in this Railscast :http://media.railscasts.com/videos/217_multistep_forms.mov. This keeps the current state>
  def steps
    %w[selection weights mobilities]
  end
  
  #array of [super_usage_id, weight_for_user] 
  def selected_super_usages
    #gets all selected super usages
    result = []
    usage_choices.where(:is_selected => true).all.each {|uc| result << [Usage.find(uc.usage_id).super_usage_id, uc.weight_for_user]}
    result.uniq!
    result
  end

  def mobility_choices
    mobilities_id = SuperUsage.where(:name => "Mobilite").first.usages.all.collect{|m| m.id}
    mobility_choices = usage_choices.select {|uc| mobilities_id.include?(uc.usage_id) }
  end

  def update_selection params
    @usage_choices_selected=[]
    params.keys.each do |param_key|
      #list of usage_choices to be selected
      if param_key =~ /usage_choice_selected_./
        @usage_choices_selected << Integer(param_key.split('_').last)
      end
    end
    raise I18n.t(:no_usage_selected_error) if @usage_choices_selected.empty?
    #update of is_selected for each usage_choice
    usage_choices.each do |uc|
      unless uc.usage.super_usage.name == "Mobilite"
        uc.update_attributes :is_selected => @usage_choices_selected.include?(uc.id)
      end
    end
  end

  def update_weights params
    are_weights_selected = false
    params.each do |key, weight_for_user|
      if key =~ /super_usage_weight_./
        are_weights_selected = true if weight_for_user.to_i > 0
        super_usage_id = key.split('_').last
        begin
          usage_choices_to_update = SuperUsage.find(super_usage_id).usages.collect {|u| usage_choices.where(:usage_id => u.id).first}
        rescue
          raise I18n.t(:weights_step_wrong_choices) unless uc.update_attributes(:weight_for_user => weight_for_user.to_i)
        end
        usage_choices_to_update.each do |uc|
        raise I18n.t(:weights_step_wrong_choices) unless uc.update_attributes(:weight_for_user => weight_for_user.to_i)
        end
      end
    end
    raise I18n.t(:weights_step_no_choices) unless are_weights_selected
  end

  def submit_and_get_response params
    #update mobility choices
    params.each do |key, weight_for_user|
      if key =~ /mobility_weight_./
        mobility_choice_id = key.split('_').last
        begin
          usage_choice = UsageChoice.find(mobility_choice_id)
        rescue 
          raise I18n.t(:mobilities_step_wrong_choices)
        end
        raise I18n.t(:mobilities_step_wrong_choices) unless usage_choice.update_attributes(:weight_for_user => weight_for_user)
      end
    end
    UserRequest.find(params[:id]).update_attributes(:is_complete => true)
    load 'user_response.rb'
    director = UserResponseDirector.new
    director.init_builder self 
    director.process_response
    user_response = director.get_response
    director.clear!
    user_response
  end
end
