class ArticlesController < ApplicationController
  before_filter :check_user_login, :only => [:new, :edit, :create, :update, :destroy]
  # GET /articles
  # GET /articles.xml
  def index
    @articles = Article.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    @article = Article.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = Article.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
  end

  # POST /articles
  # POST /articles.xml
  def create
    raise "unknown user #{params[:user_name]}" unless User.where(:name => params[:user_name]).first 
    @article = Article.new(
      :title => params[:article][:title],
      :summary => params[:article][:summary],
      :meta => params[:article][:meta],
      :body => params[:article][:body],
      :user => User.where(:name => params[:user_name]).first
    )

    create_tag_article_association

    respond_to do |format|
      if @article.save
        format.html { redirect_to(@article, :notice => 'Article was successfully created.') }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    @article = Article.find(params[:id])
    new_params = {
      :title => params[:article][:title],
      :summary => params[:article][:summary],
      :meta => params[:article][:meta],
      :body => params[:article][:body],
      :user => User.where(:name => params[:user_name]).first
    }
    @article.tag_article_associations.delete_all
    create_tag_article_association params
    redirect_to @article
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
    end
  end
  
  private

  def check_user_login
    redirect_to :root unless current_user
  end

  private

  def create_tag_article_association params
    params.keys.each do |key|
      if key =~ /^tag_./
        tag_name = key.split('tag_').last
        if tag = Tag.where(:name => tag_name).first 
          tag_article_association = TagArticleAssociation.new(:tag => tag, :article => @article)
          tag_article_association.save
        else
          raise "tag #{tag_name} does not exist"
        end
      end
    end
  end
end
