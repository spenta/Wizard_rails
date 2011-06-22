class TagsController < ApplicationController
  def new
    @tag = Tag.new
    redirect_to :root unless current_user
  end

  def create
    @tag = Tag.new(params[:tag])
    if @tag.save
      redirect_to root_url
    else
      render "new"
    end
  end

  def index
  end

end
