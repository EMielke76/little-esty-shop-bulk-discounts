class MerchantDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:id])
  end

  def show

  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.new(bulk_discount_params)

    if discount.save(bulk_discount_params)
      merchant.bulk_discounts.push(discount)
      redirect_to "/merchants/#{merchant.id}/discounts"
    else
      flash[:messages] = discount.errors.full_messages
      redirect_to "/merchants/#{merchant.id}/discounts/new"
    end
  end

  private

  def bulk_discount_params
    params.permit(:percent_discount, :threshold, :merchant_id)
  end
end
