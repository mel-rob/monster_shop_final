class Merchant::CouponsController < Merchant::BaseController

  def index
    @coupons = Coupon.where(merchant_id: current_user.merchant_id)
  end

  def new
    @coupon = Coupon.new
  end

  def edit
    @coupon = Coupon.find(params[:id])
  end

  def show
    @coupon = Coupon.find(params[:id])
  end

  def create
    merchant = current_user.merchant
    @coupon = merchant.coupons.new(coupon_params)
    if @coupon.save
      flash[:success] = 'Coupon created!'
      redirect_to merchant_coupons_path
    else
      flash[:error] = "#{@coupon.errors.full_messages.to_sentence}. Please try again."
      render :new
    end
  end

  def update
    @coupon = Coupon.find(params[:format])
    if @coupon.update(coupon_params)
      flash[:success] = 'Coupon updated!'
      redirect_to merchant_coupons_path
    else
      flash[:error] = "#{@coupon.errors.full_messages.to_sentence}. Please try again."
      render :edit
    end
  end

  def destroy
    Coupon.destroy(params[:id])
    flash[:success] = "Coupon deleted!"
    redirect_to merchant_coupons_path
  end

private
  def coupon_params
    params.require(:coupon).permit(:name, :percentage_off, :code)
  end
end
