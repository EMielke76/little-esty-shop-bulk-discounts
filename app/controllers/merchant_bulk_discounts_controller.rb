class MerchantBulkDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.new()
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.new(bulk_discount_params)

    if discount.valid?
      merchant.bulk_discounts.push(discount)
      redirect_to merchant_bulk_discounts_path(merchant)
    else
      flash[:messages] = discount.errors.full_messages
      redirect_to new_merchant_bulk_discount_path(merchant)
    end
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def update
    discount = BulkDiscount.find(params[:id])
    discount.update(bulk_discount_params)

    if discount.valid?
      redirect_to merchant_bulk_discount_path(params[:merchant_id], discount)
    else
      flash[:messages] = discount.errors.full_messages
      redirect_to edit_merchant_bulk_discount_path(params[:merchant_id], discount)
    end
  end

  def destroy
    discount = BulkDiscount.find(params[:id])
    discount.destroy
    redirect_to merchant_bulk_discounts_path(params[:merchant_id])
  end

  private

  def bulk_discount_params
    params.permit(:percent_discount, :threshold, :merchant_id)
  end
end
