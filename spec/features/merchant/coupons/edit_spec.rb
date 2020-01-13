require 'rails_helper'

RSpec.describe 'Coupons Index' do
  describe 'As a Merchant' do
    before :each do
      @merchant_1 = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @coupon_1 = @merchant_1.coupons.create!(name: 'Black Friday', percentage_off: 20, code: 'BF2019')
      @coupon_2 = @merchant_1.coupons.create!(name: 'Mega Sale', percentage_off: 10, code: 'mega10')

      @user_1 = @merchant_1.users.create!(name: 'Melissa R.', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218, email: 'melissar@gmail.com', password: 'password')

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)
    end

    it 'I see a link to edit each individual coupon' do

      visit '/merchant/coupons'

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_button('Edit')
      end

      within "#coupon-#{@coupon_2.id}" do
        expect(page).to have_button('Edit')
      end
    end

    it 'When I click on a link to edit a coupon I am taken to the edit page where I can edit the coupon' do

      original_name = @coupon_1.name
      original_percentage_off = number_to_percentage(@coupon_1.percentage_off, precision: 0)
      original_code = @coupon_1.code

      visit '/merchant/coupons'

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_content(original_name)
        expect(page).to have_content(original_code)
        expect(page).to have_content(original_percentage_off)
        click_button('Edit')
      end

      expect(current_path).to eq(edit_merchant_coupon_path(@coupon_1.id))

      expect(find_field("Name").value).to eq(@coupon_1.name)
      expect(find_field("Percentage off").value).to eq(@coupon_1.percentage_off.to_s)
      expect(find_field("Code").value).to eq(@coupon_1.code)

      new_name = "New Name"
      new_percentage_off = 10
      new_code = "NewCode"

      fill_in "Name", with: new_name
      fill_in "Percentage off", with: new_percentage_off
      fill_in "Code", with: new_code

      click_button 'Submit'

      expect(current_path).to eq(merchant_coupons_path)
      expect(page).to have_content('Coupon updated!')

      within "#coupon-#{@coupon_1.id}" do
        expect(page).to have_content(new_name)
        expect(page).to have_content(new_percentage_off)
        expect(page).to have_content(new_code)
      end
    end

    it 'I am unable to edit a coupon without filling in required fields' do

      visit edit_merchant_coupon_path(@coupon_2)

      new_name = ""
      new_percentage_off = 10
      new_code = "NewCode"

      fill_in "Name", with: new_name
      fill_in "Percentage off", with: new_percentage_off
      fill_in "Code", with: new_code

      click_button 'Submit'

      expect(page).to have_content("Name can't be blank. Please try again.")
      expect(page).to have_button('Submit')

      fill_in "Name", with: "New Name"
      fill_in "Percentage off", with: nil
      fill_in "Code", with: "New Code"

      click_button 'Submit'

      expect(page).to have_content("Percentage off can't be blank. Please try again.")
      expect(page).to have_button('Submit')

      fill_in "Name", with: "New Name"
      fill_in "Percentage off", with: 10
      fill_in "Code", with: ""

      click_button 'Submit'

      expect(page).to have_content("Code can't be blank. Please try again.")
      expect(page).to have_button('Submit')
    end
  end
end
