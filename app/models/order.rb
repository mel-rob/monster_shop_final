class Order < ApplicationRecord
  has_many :order_items
  has_many :items, through: :order_items

  belongs_to :user
  belongs_to :coupon, optional: true

  enum status: ['pending', 'packaged', 'shipped', 'cancelled']

  def grand_total
    order_items.sum('price * quantity')
  end

  def count_of_items
    order_items.sum(:quantity)
  end

  def coupon
    Coupon.find(coupon_id) if coupon_id 
  end

  def cancel
    update(status: 'cancelled')
    order_items.each do |order_item|
      order_item.update(fulfilled: false)
      order_item.item.update(inventory: order_item.item.inventory + order_item.quantity)
    end
  end

  def merchant_subtotal(merchant_id)
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .where("items.merchant_id = #{merchant_id}")
      .sum('order_items.price * order_items.quantity')
  end

  def merchant_quantity(merchant_id)
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .where("items.merchant_id = #{merchant_id}")
      .sum('order_items.quantity')
  end

  def is_packaged?
    update(status: 1) if order_items.distinct.pluck(:fulfilled) == [true]
  end

  def self.by_status
    order(:status)
  end

  def original_subtotal
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .sum("items.price * order_items.quantity")
    end

  def total_discounts
    original_total =
    order_items
      .joins("JOIN items ON order_items.item_id = items.id")
      .sum("items.price * order_items.quantity")
    discounted_total = order_items.sum('price * quantity')
    original_total - discounted_total
  end

  def discounted_grand_total
    order_items.sum('price * quantity')
  end
end
