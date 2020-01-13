require 'rails_helper'

RSpec.describe 'Coupons show page' do
  describe 'As a Merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @coupon_1 = @merchant_1.coupons.create!(name: 'Black Friday', percentage_off: 20, code: 'BF2019')
      @coupon_2 = @merchant_1.coupons.create!(name: 'Mega Sale', percentage_off: 10, code: 'mega10')

      @user_1 = @merchant_1.users.create!(name: 'Melissa R.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissar@gmail.com', password: 'password')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)
    end

    it 'I can see an individual coupon with its information' do

      visit merchant_coupon_path(@coupon_1)

      expect(page).to have_content(@coupon_1.name)
      expect(page).to have_content(number_to_percentage(@coupon_1.percentage_off, precision: 0))
      expect(page).to have_content(@coupon_1.code)

      expect(page).to_not have_content(@coupon_2.name)
      expect(page).to_not have_content(number_to_percentage(@coupon_2.percentage_off, precision: 0))
      expect(page).to_not have_content(@coupon_2.code)

      expect(page).to have_button('Edit')

      visit merchant_coupon_path(@coupon_2)

      expect(page).to have_content(@coupon_2.name)
      expect(page).to have_content(number_to_percentage(@coupon_2.percentage_off, precision: 0))
      expect(page).to have_content(@coupon_2.code)

      expect(page).to_not have_content(@coupon_1.name)
      expect(page).to_not have_content(number_to_percentage(@coupon_1.percentage_off, precision: 0))
      expect(page).to_not have_content(@coupon_1.code)

      expect(page).to have_button('Edit')
    end
  end
end
