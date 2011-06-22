class AdminController < ApplicationController
  def show
    redirect_to :root unless current_user
  end 
end
