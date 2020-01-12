require 'rails_helper'

RSpec.describe 'Coupons Index' do
  describe 'As a Merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_2 = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @merchant_3 = Merchant.create!(name: 'Pinwheel Coffee', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @coupon_1 = @merchant_1.coupons.create!(name: 'Black Friday', percentage_off: 20, code: 'BF2019')
      @coupon_2 = @merchant_1.coupons.create!(name: 'Mega Sale', percentage_off: 10, code: 'mega10')

      @coupon_3 = @merchant_2.coupons.create!(name: 'New Customer', percentage_off: 15, code: 'welcome15')

      @user_1 = @merchant_1.users.create!(name: 'Melissa R.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissar@gmail.com', password: 'password')
      @user_2 = @merchant_2.users.create!(name: 'Melissa M.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissam@gmail.com', password: 'password')
      @user_3 = @merchant_3.users.create!(name: 'Melissa H.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissah@gmail.com', password: 'password')
    end

    it 'I can see an index of all my coupons' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit '/merchant/coupons'

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_content(@coupon_1.name)
        expect(page).to have_content(number_to_percentage(@coupon_1.percentage_off, precision: 0))
        expect(page).to have_content(@coupon_1.code)
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_content(@coupon_2.name)
        expect(page).to have_content(number_to_percentage(@coupon_2.percentage_off, precision: 0))
        expect(page).to have_content(@coupon_2.code)
      end
    end

    it 'I see a message indicating I have no coupons if I have not created any' do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_3)

      visit '/merchant/coupons'

      expect(page).to have_content('There are no coupons in the system.')
    end
  end
end
