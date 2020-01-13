require 'rails_helper'

RSpec.describe 'Coupons Index' do
  describe 'As a Merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @coupon_1 = @merchant_1.coupons.create!(name: 'Black Friday', percentage_off: 20, code: 'BF2019')

      @user_1 = @merchant_1.users.create!(name: 'Melissa R.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissar@gmail.com', password: 'password')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)
    end

    it 'I see a link to create a coupon' do

      visit merchant_coupons_path

      expect(page).to have_button('Create Coupon')
    end

    it 'When I click the link to create a coupon I am taken to the new coupon form' do

      visit '/merchant/coupons'

      click_button 'Create Coupon'

      expect(current_path).to eq(new_merchant_coupon_path)
    end

    it 'I can fill out the fields to create a new coupon and see a flash message when coupon is created' do

      visit '/merchant/coupons/new'

      fill_in "Name", with: 'New Customer'
      fill_in "Percentage off", with: 15
      fill_in "Code", with: 'WELCOME15'
      click_button 'Submit'

      expect(current_path).to eq(merchant_coupons_path)

      expect(page).to have_content('Coupon created!')

      expect(page).to have_content('New Customer')
      expect(page).to have_content('15%')
      expect(page).to have_content('WELCOME15')
    end

    it 'I am unable to create a coupon without filling in required fields' do

      visit '/merchant/coupons/new'

      fill_in "Name", with: ''
      fill_in "Percentage off", with: 15
      fill_in "Code", with: 'WELCOME15'
      click_button 'Submit'

      expect(page).to have_button 'Submit'
      expect(page).to have_content "Name can't be blank"

      fill_in "Name", with: 'Welcome New Customer!'
      fill_in "Percentage off", with: ''
      fill_in "Code", with: 'New10'
      click_button 'Submit'

      expect(page).to have_button 'Submit'
      expect(page).to have_content "Percentage off can't be blank"

      fill_in "Name", with: 'Welcome New Customer!'
      fill_in "Percentage off", with: 10
      fill_in "Code", with: ''
      click_button 'Submit'

      expect(page).to have_button 'Submit'
      expect(page).to have_content "Code can't be blank"

      fill_in "Name", with: 'Welcome New Customer!'
      fill_in "Percentage off", with: 10
      fill_in "Code", with: 'Welcome10'
      click_button 'Submit'

      expect(current_path).to eq(merchant_coupons_path)
      expect(page).to have_content('Coupon created!')
    end

    it 'I am unable to create a coupon that has the same name or code as another coupon' do

      visit new_merchant_coupon_path

      fill_in "Name", with: 'New Customer'
      fill_in "Percentage off", with: 15
      fill_in "Code", with: 'WELCOME15'
      click_button 'Submit'

      expect(current_path).to eq(merchant_coupons_path)

      expect(page).to have_content('Coupon created!')

      expect(page).to have_content('New Customer')
      expect(page).to have_content('15%')
      expect(page).to have_content('WELCOME15')

      click_button 'Create Coupon'

      fill_in "Name", with: 'New Customer'
      fill_in "Percentage off", with: 10
      fill_in "Code", with: 'WELCOME10'
      click_button 'Submit'

      expect(page).to have_button 'Submit'
      expect(page).to have_content 'Name has already been taken'

      fill_in "Name", with: 'New Customer 2'
      fill_in "Percentage off", with: 15
      fill_in "Code", with: 'WELCOME15'
      click_button 'Submit'

      expect(page).to have_button 'Submit'
      expect(page).to have_content 'Code has already been taken'

      fill_in "Name", with: 'New Customer 2'
      fill_in "Percentage off", with: 15
      fill_in "Code", with: 'welcome15'
      click_button 'Submit'

      expect(page).to have_button 'Submit'
      expect(page).to have_content 'Code has already been taken'
    end
  end
end
