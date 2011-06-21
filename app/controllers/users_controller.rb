class UsersController < ApplicationController

  def new
    unless User.count == 0 or current_user
      redirect_to :root
    else
      @user = User.new
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url
    else
      render "new"
    end
  end
end
