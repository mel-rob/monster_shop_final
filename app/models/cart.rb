class Cart
  attr_reader :contents

  def initialize(contents)
    @contents = contents || {}
    @contents.default = 0
  end

  def add_item(item_id)
    @contents[item_id] += 1
  end

  def less_item(item_id)
    @contents[item_id] -= 1
  end

  def count
    @contents.values.sum
  end

  def items
    @contents.map do |item_id, _|
      Item.find(item_id)
    end
  end

  def grand_total
    grand_total = 0.0
    @contents.each do |item_id, quantity|
      grand_total += Item.find(item_id).price * quantity
    end
    grand_total
  end

  def count_of(item_id)
    @contents[item_id.to_s]
  end

  def subtotal_of(item_id)
    @contents[item_id.to_s] * Item.find(item_id).price
  end

  def limit_reached?(item_id)
    count_of(item_id) == Item.find(item_id).inventory
  end

  def eligible_coupon?(code)
    ids = items.map {|item| item.merchant_id}
    codes = Coupon.where(merchant_id: ids).pluck(:code)
    codes.include?(code)
  end

  def total_discounts(merchant_id, percentage_off)
    multiplier = (percentage_off.to_i)/100.to_f
    @contents.sum do |item_id, quantity|
      item = Item.find(item_id)
      if item.merchant_id == merchant_id
        item.price * multiplier * quantity
      else
        0
      end
    end
  end

  def discounted_grand_total(merchant_id, percentage_off)
    multiplier = (100 - percentage_off.to_i)/100.to_f
    @contents.sum do |item_id, quantity|
      item = Item.find(item_id)
      if item.merchant_id == merchant_id
        item.price * multiplier * quantity
      else
        item.price * quantity
      end
    end
  end
end
