class UserRequestsController < ApplicationController
  # POST /user_requests
  def create
    if !request.post? 
      redirect_to :root
    else
      #session[:user_response] = nil
      reset_session
      @user_request = create_new_user_request
      redirect_to edit_user_request_path(@user_request)
    end
  end

  def index
    respond_to do |format|
      format.html {redirect_to :root}
      format.xml 
    end
  end

  # GET /user_requests/1/edit
  def edit 
    @user_request = UserRequest.find(params[:id])
    @user_request.current_step = session[:user_request_step]
    if params[:back] &&  @user_request.current_step != @user_request.steps.first
      @user_request.previous_step
      session[:user_request_step] = @user_request.current_step
    end
  end

  # PUT /user_requests/1
  def update
    @user_request = UserRequest.find(params[:id])
    @user_request.current_step = session[:user_request_step]
    begin
      case @user_request.current_step
      when "selection"
        @user_request.update_selection params
        session[:user_request_step] =  @user_request.next_step
        redirect_to edit_user_request_path 
      when "weights"
        @user_request.update_weights params
        session[:user_request_step]  = @user_request.next_step
        redirect_to edit_user_request_path
      when "mobilities"
        session[:user_response] = @user_request.submit_and_get_response params
        session[:sort_order] = :spenta_score
        @user_request.update_attributes(:is_complete => true)
        redirect_to user_response_user_request_path
        else
          raise "unknown form state : #{session[:user_request_step]}"
      end
    rescue => error
      redirect_to edit_user_request_path, :flash => {:error => error.message}
    end
  end

  def user_response
    if session[:user_response]
      session[:start_timer] = Time.new
      @user_response = session[:user_response]
    else
      redirect_to :root
    end
  end

  private
  def create_usage_choices_for super_usage, user_request, options = {:with_initial_weight => 0}
    super_usage.usages.each do |u|
      usage_choice = UsageChoice.new(:weight_for_user => options[:with_initial_weight],
                                     :usage_id => u.id,
                                     :user_request_id => user_request.id,
                                     :is_selected => false)
      usage_choice.save
    end
  end

  def create_new_user_request
    new_user_request = UserRequest.new(:is_complete => false)
    new_user_request.save
    SuperUsage.all.each do |su|
      if su.name == "Mobilite"
        create_usage_choices_for su, new_user_request 
      else
        create_usage_choices_for su, new_user_request, :with_initial_weight => 50
      end
    end
    new_user_request
  end
end
