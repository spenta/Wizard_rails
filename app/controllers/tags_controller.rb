class TagsController < ApplicationController
  def new
    @tag = Tag.new
    redirect_to :root unless current_user
  end

  def create
    @tag = Tag.new(params[:tag])
    flash[:warning] = "erreur dans la creation (tag deja existant ?)" unless @tag.save
    redirect_to tags_new_path
  end

  def index
  end

end
