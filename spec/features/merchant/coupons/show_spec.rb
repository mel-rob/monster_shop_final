require 'rails_helper'

RSpec.describe 'Coupons show page' do
  describe 'As a Merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @coupon_1 = @merchant_1.coupons.create!(name: 'Black Friday', percentage_off: 20, code: 'BF2019')
      @coupon_2 = @merchant_1.coupons.create!(name: 'Mega Sale', percentage_off: 10, code: 'mega10')

      @default_user = User.create!(name: 'Melissa D.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissad@gmail.com', password: 'password')

      @user_1 = @merchant_1.users.create!(name: 'Melissa R.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissar@gmail.com', password: 'password')

      @order_item_1 = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @order_item_2 = @merchant_1.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )

      @order_1 = @default_user.orders.create!
      @order_item_1 = @order_1.order_items.create!(item: @order_item_1, price: @order_item_1.price, quantity: 2)
      @order_item_2 = @order_1.order_items.create!(item: @order_item_2, price: @order_item_2.price, quantity: 3)

      @coupon_2.orders << @order_1

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

    it 'When I click on the edit button I am taken to an edit form' do

      visit merchant_coupon_path(@coupon_1)

      click_button 'Edit'

      expect(current_path).to eq(edit_merchant_coupon_path(@coupon_1))
    end

    it "When I click on the delete button the coupon is deleted" do

      visit merchant_coupon_path(@coupon_1)

      click_button 'Delete'

      expect(current_path).to eq(merchant_coupons_path)
      expect(page).to_not have_content(@coupon_1.name)
      expect(page).to_not have_content(number_to_percentage(@coupon_1.percentage_off, precision: 0))
      expect(page).to_not have_content(@coupon_1.code)
    end

    it "I don't see delete buttons on coupons that have already been applied" do

      visit merchant_coupon_path(@coupon_2)

      expect(page).to_not have_button('Delete')
      expect(page).to have_content('This coupon has been applied and cannot be deleted.')

      save_and_open_page
    end
  end
end
