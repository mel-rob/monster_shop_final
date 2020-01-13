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

      @default_user = User.create!(name: 'Melissa D.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissad@gmail.com', password: 'password')

      @user_1 = @merchant_1.users.create!(name: 'Melissa R.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissar@gmail.com', password: 'password')
      @user_2 = @merchant_2.users.create!(name: 'Melissa M.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissam@gmail.com', password: 'password')
      @user_3 = @merchant_3.users.create!(name: 'Melissa H.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissah@gmail.com', password: 'password')

      @order_item_1 = @merchant_1.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @order_item_2 = @merchant_1.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 10 )

      @order_1 = @default_user.orders.create!
      @order_item_1 = @order_1.order_items.create!(item: @order_item_1, price: @order_item_1.price, quantity: 2)
      @order_item_2 = @order_1.order_items.create!(item: @order_item_2, price: @order_item_2.price, quantity: 3)

      @coupon_2.orders << @order_1
    end

    it 'I can see an index of all my coupons' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit merchant_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_link(@coupon_1.name)
        expect(page).to have_content(number_to_percentage(@coupon_1.percentage_off, precision: 0))
        expect(page).to have_content(@coupon_1.code)
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_link(@coupon_2.name)
        expect(page).to have_content(number_to_percentage(@coupon_2.percentage_off, precision: 0))
        expect(page).to have_content(@coupon_2.code)
      end
    end

    it 'I see a message indicating I have no coupons if I have not created any' do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_3)

      visit merchant_coupons_path

      expect(page).to have_content('There are no coupons in the system.')
    end

    it 'I can see a link to edit and delete individual coupons' do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit merchant_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_button('Edit')
        expect(page).to have_button('Delete')
      end
    end

    it "When I click on an individual edit button I am sent to that coupon's edit page" do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit merchant_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        click_button 'Edit'
      end

      expect(current_path).to eq(edit_merchant_coupon_path(@coupon_1))
    end

    it "When I click on an individual delete button the coupon is deleted" do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit merchant_coupons_path

      within "#coupon-#{@coupon_1.id}" do
        click_button 'Delete'
      end

      expect(current_path).to eq(merchant_coupons_path)
      expect(page).to_not have_content(@coupon_1.name)
    end

    it "I don't see delete buttons on coupons that have already been applied" do

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      visit merchant_coupons_path

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to_not have_button('Delete')
        expect(page).to have_content('This coupon has been applied and cannot be deleted.')
      end
    end
  end
end
