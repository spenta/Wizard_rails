class UsageChoicesController < ApplicationController
  # PUT /usage_choices/1
  # PUT /usage_choices/1.xml
  def update
    @usage_choice = UsageChoice.find(params[:id])

    respond_to do |format|
      if @usage_choice.update_attributes(params[:usage_choice])
        format.html { redirect_to(@usage_choice.user_request, :notice => 'User request was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@usage_choice.user_request, :notice => "invalid choice") }
        format.xml  { render :xml => @usage_choice.errors, :status => :unprocessable_entity }
      end
    end
  end
end
