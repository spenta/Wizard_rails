class UserRequest < ActiveRecord::Base
  attr_writer :current_step

  def current_step
    @current_step || steps.first
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  has_many :usage_choices, :dependent => :destroy
  
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
    raise I18n.t(:usage_selection_error) unless update_attributes(params[:user_request])
    #update of is_selected for each usage_choice
    usage_choices.each do |uc|
      unless uc.usage.super_usage.name == "Mobilite"
        uc.update_attributes :is_selected => @usage_choices_selected.include?(uc.id)
      end
    end
    raise I18n.t(:no_usage_selected_error) if @usage_choices_selected.empty?
  end

  def update_weights params
    params.each do |key, weight_for_user|
      if key =~ /super_usage_weight_./
        super_usage_id = key.split('_').last
        usage_choices_to_update = SuperUsage.find(super_usage_id).usages.collect {|u| usage_choices.where(:usage_id => u.id).first}
        usage_choices_to_update.each {|uc| uc.update_attributes :weight_for_user => weight_for_user.to_i}
      end
    end
  end

  def submit_and_get_response params
    #update mobility choices
    params.each do |key, weight_for_user|
      if key =~ /mobility_weight_./
        mobility_choice_id = key.split('_').last
        UsageChoice.find(mobility_choice_id).update_attributes(:weight_for_user => weight_for_user)
      end
    end
    load 'user_response.rb'
    director = UserResponseDirector.new
    director.init_builder self 
    director.process_response
    user_response = director.get_response
    director.clear!
    user_response
  end
end
