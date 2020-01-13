require 'rails_helper'

RSpec.describe Coupon do
  describe 'relationships' do

    it {should belong_to :merchant}
    it {should have_many :orders}
  end

  describe 'validations' do

    it {should validate_presence_of :name}
    it {should validate_uniqueness_of(:name).ignoring_case_sensitivity}

    it {should validate_presence_of :percentage_off}
    it {should validate_numericality_of(:percentage_off).is_greater_than(0)}
    it {should validate_numericality_of(:percentage_off).is_less_than_or_equal_to(100)}

    it {should validate_presence_of :code}
    it {should validate_uniqueness_of(:code).ignoring_case_sensitivity}
  end

  describe 'model methods' do

    it '#never_applied?' do
      merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      coupon_1 = merchant_1.coupons.create!(name: 'Black Friday', percentage_off: 20, code: 'BF2019')
      coupon_2 = merchant_1.coupons.create!(name: 'Mega Sale', percentage_off: 10, code: 'mega10')

      user_1 = User.create!(name: 'Melissa R.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissar@gmail.com', password: 'password')

      order_item_1 = merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      order_item_2 = merchant_1.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )

      order_1 = user_1.orders.create!
      order_item_1 = order_1.order_items.create!(item: order_item_1, price: order_item_1.price, quantity: 2)
      order_item_2 = order_1.order_items.create!(item: order_item_2, price: order_item_2.price, quantity: 3)

      coupon_1.orders << order_1

      expect(coupon_1.never_applied?).to eq(false)
      expect(coupon_2.never_applied?).to eq(true)
    end
  end
end
