class UserRequestsController < ApplicationController
  # GET /user_requests
  # GET /user_requests.xml
  def index
    @user_requests = UserRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_requests }
    end
  end

  # GET /user_requests/1
  # GET /user_requests/1.xml
  def show
    @user_request = UserRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_request }
    end
  end

  # GET /user_requests/new
  # GET /user_requests/new.xml
  def new
    @user_request = UserRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_request }
    end
  end

  # GET /user_requests/1/edit
  def edit
    @user_request = UserRequest.find(params[:id])
  end

  # POST /user_requests
  # POST /user_requests.xml
  def create
    @user_request = UserRequest.new(params[:user_request])

    respond_to do |format|
      if @user_request.save
        SuperUsage.all.each do |su|
          su.usages.each do |u|
            usage_choice = UsageChoice.new(:weight_for_user => 0,
                                           :usage_id => u.id,
                                           :user_request_id => @user_request.id)
            usage_choice.save
          end
        end
        format.html { redirect_to(@user_request, :notice => 'User request was successfully created.') }
        format.xml  { render :xml => @user_request, :status => :created, :location => @user_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_requests/1
  # PUT /user_requests/1.xml
  def update
    @user_request = UserRequest.find(params[:id])
    @super_usage_choices = {}
    @user_request.update!
    begin
      @usage_choices_selected=[]
      params.keys.each do |param_key|
        #update of weight for usage_choices except for mobilities
        if param_key =~ /super_usage_choice_./
          @super_usage_to_update_id = param_key.split('_').last
          @usages_to_update_id = SuperUsage.find(@super_usage_to_update_id).usages
          @usage_choices_to_update = @user_request.usage_choices.where(:usage_id => @usages_to_update_id)
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
      raise "invalid response parameters given" unless @user_request.update_attributes(params[:user_request])
      #update of is_selected for each usage_choice
      @user_request.usage_choices.each do |uc|
        unless uc.usage.super_usage.name == "Mobilite"
          uc.update_attributes :is_selected => @usage_choices_selected.include?(uc.id) 
        end
      end
      #error handling
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to edit_user_request_path, :notice => "Errors in choices !\n error : #{e.message}" }
        format.xml  { render :xml => @user_request.errors, :status => :unprocessable_entity }
      end
    else
      respond_to do |format|
        format.html { redirect_to(@user_request, :notice => "User request was successfully updated.") }
        format.xml  { head :ok }
      end
    end
  end

  # DELETE /user_requests/1
  # DELETE /user_requests/1.xml
  def destroy
    @user_request = UserRequest.find(params[:id])
    @user_request.destroy

    respond_to do |format|
      format.html { redirect_to(user_requests_url) }
      format.xml  { head :ok }
    end
  end
  
end
