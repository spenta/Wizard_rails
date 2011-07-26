class TagsController < ApplicationController
  before_filter :check_user_login
  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params[:tag])
    flash[:warning] = "erreur dans la creation (tag deja existant ?)" unless @tag.save
    redirect_to tags_new_path
  end

  def index
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

  private

  def check_user_login
    redirect_to :root unless current_user
  end

end
