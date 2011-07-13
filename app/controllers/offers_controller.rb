class OffersController < ApplicationController
  def show
    @offer = Offer.find(params[:id].split('-').last)
  end

end
