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
      redirect_to edit_user_request_path, :flash => {:error => "#{error.message}\n#{error.backtrace}"}
    end
  end

  def user_response
    if session[:user_response]
      session[:start_timer] = Time.new
      @user_response = session[:user_response]
      #used for pagination
      #sort_response! @user_response.products_for_display, :by => params[:sort], :order => params[:direction]
      #request_options = process_request_options({:start_index => params[:start_index], :num_result => params[:num_result]})
      #@start_index = request_options[:start_index]
      #@num_result = request_options[:num_result]
    else
      redirect_to :root
    end
  end

  private

  #used for pagination
  #def sort_response!(ary, options = {:by => 'score', :order => 'desc'})
    #case options[:by]
    #when 'score' then ary.sort! {|p2, p1| p1.spenta_score <=> p2.spenta_score}
    #when 'price' then ary.sort! {|p2, p1| p1.price <=> p2.price}
    #when 'brand' then ary.sort! {|p1, p2| Product.find(p1.product_id).brand.name <=> Product.find(p2.product_id).brand.name}
    #when 'name' then ary.sort! {|p1, p2| Product.find(p1.product_id).name <=> Product.find(p2.product_id).name}
    #when 'medals'
      ##create 3 different arrays, sorts them and concatenate them
      #stars = ary.select {|p| p.is_star}
      #good_deals = ary.select {|p| p.is_good_deal && !p.is_star}
      #rest = ary.reject {|p| p.is_good_deal}
      #sort_response! stars, :by => 'score'
      #sort_response! good_deals, :by => 'score'
      #sort_response! rest, :by => 'score'
      #ary.clear
      #new_ary = (stars + good_deals + rest)
      #new_ary.each { |p| ary << p }
    #else ary.sort! {|p2, p1| p1.spenta_score <=> p2.spenta_score}
    #end
    #ary.reverse! if options[:order] == "asc"
  #end

  #used for pagination
  #def process_request_options options
    #result = {}
    #options[:start_index] ||= 0
    #options[:num_result] ||= 10
    #start_index = [options[:start_index].to_i, 0].max
    #num_result = [options[:num_result].to_i, 5].max
    #result = {:start_index => start_index, :num_result => num_result}
  #end

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
