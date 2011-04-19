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

  # GET /user_requests/1/edit
  def edit
    @user_request = UserRequest.find(params[:id])
  end

  # POST /user_requests
  # POST /user_requests.xml
  def create
    @user_request = UserRequest.new(:is_complete => false)

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
        format.html { redirect_to edit_user_request_path(@user_request), :notice => 'User request was successfully created.' }
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
    begin
      @user_request.update! params
      load 'user_response/user_response.rb'
      director = UserResponseDirector.new
      director.init_builder @user_request
      director.process_response
      user_response = director.get_response
      @user_request.update_attributes(:is_complete => true)
      respond_to do |format|
        format.html {render :action => 'user_response', :locals => {:user_response => user_response}}
        format.xml  { head :ok }
      end
    rescue => e
      respond_to do |format|
        format.html { redirect_to edit_user_request_path(@user_request), :notice => "Errors in choices !\n #{e.message}" }
        format.xml  { render :xml => errors, :status => :unprocessable_entity }
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

