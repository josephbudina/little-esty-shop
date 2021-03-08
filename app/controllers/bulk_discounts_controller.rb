class BulkDiscountsController < ApplicationController
  before_action :find_merchant

  def index
    @bulk_discounts = @merchant.bulk_discounts
  end
  
  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
  end

  def edit
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def create
    @bulk_discount = @merchant.bulk_discounts.new(bulk_params)
    if @bulk_discount.valid?
      @bulk_discount.save

      redirect_to merchant_bulk_discounts_path(@merchant)
    else
      flash[:notice] = "Fields Missing: Fill in all fields"

      redirect_to new_merchant_bulk_discount_path(@merchant)
    end
  end

  def destroy
    @bulk_discount = @merchant.bulk_discounts.find(params[:id])
    @bulk_discount.destroy
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end

  def bulk_params
    params.permit(:percentage_discount, :threshold)
  end
end