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
   

  def update! params
    @super_usage_choices = {}
    @usage_choices_selected=[]
    are_any_usage_scored = 0
    params.keys.each do |param_key|
      #update of weight for usage_choices except for mobilities
      if param_key =~ /super_usage_choice_./
        @super_usage_to_update_id = param_key.split('_').last
        @usages_to_update_id = SuperUsage.find(@super_usage_to_update_id).usages
        @usage_choices_to_update = usage_choices.where(:usage_id => @usages_to_update_id)
        @usage_choices_to_update.each do |uc|
          #if there is at least one usage chosen, tell that at least one usage is scored
          raise "invalid number given for usage #{uc.usage.name}" unless uc.update_attributes :weight_for_user => params[param_key]
          are_any_usage_scored += 1 if params[param_key].to_i > 0
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
    raise "Veuillez noter au moins un usage !" if are_any_usage_scored == 0
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
  end

  def submit params
    @user_request = UserRequest.find(params[:id])
    load 'user_response/user_response.rb'
    director = UserResponseDirector.new
    director.init_builder @user_request
    director.process_response
    user_response = director.get_response
    director.clear!
    session[:user_response] = user_response
    session[:sort_order] = :spenta_score
    @user_request.update_attributes(:is_complete => true)
    respond_to do |format|
      format.html {redirect_to user_response_user_request_path}
      format.xml  { head :ok }
    end
  end

end
