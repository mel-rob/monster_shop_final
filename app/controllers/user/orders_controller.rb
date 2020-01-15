class User::OrdersController < ApplicationController
  before_action :exclude_admin

  def index
    @orders = current_user.orders
  end

  def show
    @order = current_user.orders.find(params[:id])
  end

  def create
    order = current_user.orders.new
    order.coupon_id = current_coupon.id if current_coupon
    order.save
      cart.items.each do |item|
        if order.coupon_id
          coupon = Coupon.find(order.coupon_id)
          adjusted_price = item.discounted_price(coupon.merchant_id, coupon.percentage_off)
        else
          adjusted_price = item.price
        end
      order.order_items.create({
        item: item,
        quantity: cart.count_of(item.id),
        price: adjusted_price
          })
      end
    session.delete(:cart)
    session.delete(:current_coupon)
    flash[:notice] = "Order created successfully!"
    redirect_to '/profile/orders'
  end

  def cancel
    order = current_user.orders.find(params[:id])
    order.cancel
    redirect_to "/profile/orders/#{order.id}"
  end
end
