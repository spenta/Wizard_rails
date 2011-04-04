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

    respond_to do |format|
      if @user_request.update_attributes(params[:user_request])
        format.html { redirect_to(@user_request, :notice => 'User request was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_request.errors, :status => :unprocessable_entity }
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
