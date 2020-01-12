class Merchant::CouponsController < Merchant::BaseController

  def index
    @merchant = current_user.merchant
  end

  def new
  end

  def create
    merchant = current_user.merchant
    coupon = merchant.coupons.new(coupon_params)
    if coupon.save
      flash[:success] = 'Coupon created!'
      redirect_to merchant_coupons_path
    else
      flash[:error] = coupon.errors.full_messages.to_sentence
      render :new
    end
  end

private
  def coupon_params
    params.permit(:name, :percentage_off, :code)
  end
end
