class MerchantDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:id])
  end

  def show

  end

  def new
    require "pry"; binding.pry
  end
end
