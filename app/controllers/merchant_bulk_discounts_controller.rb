class MerchantBulkDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:discount_id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.new(bulk_discount_params)

    if discount.save(bulk_discount_params)
      merchant.bulk_discounts.push(discount)
      redirect_to "/merchants/#{merchant.id}/bulk_discounts"
    else
      flash[:messages] = discount.errors.full_messages
      redirect_to "/merchants/#{merchant.id}/bulk_discounts/new"
    end
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:discount_id])
  end

  def update
    discount = BulkDiscount.find(params[:discount_id])
    discount.update(bulk_discount_params)
    if discount.valid?
      redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts/#{discount.id}"
    else
      flash[:messages] = discount.errors.full_messages
      redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts/#{discount.id}/edit"
    end
  end


  def destroy
    discount = BulkDiscount.find(params[:discount_id])
    discount.destroy
    redirect_to "/merchants/#{params[:merchant_id]}/bulk_discounts"
  end

  private

  def bulk_discount_params
    params.permit(:percent_discount, :threshold, :merchant_id)
  end
end