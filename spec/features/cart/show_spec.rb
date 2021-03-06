require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.describe 'Cart Show Page' do
  describe 'As a Visitor' do
    before :each do
      @megan = Merchant.create!(name: 'Megans Marmalades', address: '123 Main St', city: 'Denver', state: 'CO', zip: 80218)
      @brian = Merchant.create!(name: 'Brians Bagels', address: '125 Main St', city: 'Denver', state: 'CO', zip: 80218)

      @coupon_1 = @megan.coupons.create!(name: 'Black Friday', percentage_off: 20, code: 'BF2019')
      @coupon_2 = @brian.coupons.create!(name: 'Mega Sale', percentage_off: 10, code: 'Mega10')

      @ogre = @megan.items.create!(name: 'Ogre', description: "I'm an Ogre!", price: 20, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 5 )
      @giant = @megan.items.create!(name: 'Giant', description: "I'm a Giant!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
      @hippo = @brian.items.create!(name: 'Hippo', description: "I'm a Hippo!", price: 50, image: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTaLM_vbg2Rh-mZ-B4t-RSU9AmSfEEq_SN9xPP_qrA2I6Ftq_D9Qw', active: true, inventory: 3 )
    end

    describe 'I can see my cart' do
      it "I can visit a cart show page to see items in my cart" do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        expect(page).to have_content("Total: #{number_to_currency((@ogre.price * 1) + (@hippo.price * 2))}")

        within "#item-#{@ogre.id}" do
          expect(page).to have_link(@ogre.name)
          expect(page).to have_content("Price: #{number_to_currency(@ogre.price)}")
          expect(page).to have_content("Quantity: 1")
          expect(page).to have_content("Subtotal: #{number_to_currency(@ogre.price * 1)}")
          expect(page).to have_content("Sold by: #{@megan.name}")
          expect(page).to have_css("img[src*='#{@ogre.image}']")
          expect(page).to have_link(@megan.name)
        end

        within "#item-#{@hippo.id}" do
          expect(page).to have_link(@hippo.name)
          expect(page).to have_content("Price: #{number_to_currency(@hippo.price)}")
          expect(page).to have_content("Quantity: 2")
          expect(page).to have_content("Subtotal: #{number_to_currency(@hippo.price * 2)}")
          expect(page).to have_content("Sold by: #{@brian.name}")
          expect(page).to have_css("img[src*='#{@hippo.image}']")
          expect(page).to have_link(@brian.name)
        end
      end

      it "I can visit an empty cart page" do
        visit '/cart'

        expect(page).to have_content('Your Cart is Empty!')
        expect(page).to_not have_button('Empty Cart')
      end
    end

    describe 'I can manipulate my cart' do
      it 'I can empty my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        click_button 'Empty Cart'

        expect(current_path).to eq('/cart')
        expect(page).to have_content('Your Cart is Empty!')
        expect(page).to have_content('Cart: 0')
        expect(page).to_not have_button('Empty Cart')
      end

      it 'I can remove one item from my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('Remove')
        end

        expect(current_path).to eq('/cart')
        expect(page).to_not have_content("#{@hippo.name}")
        expect(page).to have_content('Cart: 1')
        expect(page).to have_content("#{@ogre.name}")
      end

      it 'I can add quantity to an item in my cart' do
        visit item_path(@ogre)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('More of This!')
        end

        expect(current_path).to eq('/cart')
        within "#item-#{@hippo.id}" do
          expect(page).to have_content('Quantity: 3')
        end
      end

      it 'I can not add more quantity than the items inventory' do
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          expect(page).to_not have_button('More of This!')
        end

        visit "/items/#{@hippo.id}"

        click_button 'Add to Cart'

        expect(page).to have_content("You have all the item's inventory in your cart already!")
      end

      it 'I can reduce the quantity of an item in my cart' do
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('Less of This!')
        end

        expect(current_path).to eq('/cart')
        within "#item-#{@hippo.id}" do
          expect(page).to have_content('Quantity: 2')
        end
      end

      it 'if I reduce the quantity to zero, the item is removed from my cart' do
        visit item_path(@hippo)
        click_button 'Add to Cart'

        visit '/cart'

        within "#item-#{@hippo.id}" do
          click_button('Less of This!')
        end

        expect(current_path).to eq('/cart')
        expect(page).to_not have_content("#{@hippo.name}")
        expect(page).to have_content("Cart: 0")
      end
    end

    it 'I see a field to add a coupon code' do
      visit item_path(@ogre)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'

      visit '/cart'

      expect(page).to have_content('Coupon code')
      find_field(:coupon_code)
      expect(page).to have_button('Submit')
    end

    it 'I can enter in a coupon code and apply it to my cart' do
      visit item_path(@ogre)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'

      visit '/cart'

      fill_in :coupon_code, with: 'BF2019'
      click_button 'Submit'

      expect(page).to have_content('BF2019 coupon applied!')
      expect(page).to have_content('BF2019 coupon currently applied.')

      fill_in :coupon_code, with: 'Mega10'
      click_button 'Submit'

      expect(page).to have_content('Mega10 coupon applied!')
      expect(page).to have_content('Mega10 coupon currently applied.')

      expect(page).to_not have_content('BF2019 coupon currently applied.')

      fill_in :coupon_code, with: 'LameCoupon'
      click_button 'Submit'

      expect(page).to have_content('This coupon does not exist or is not valid for these items.')
      expect(page).to have_content('Mega10 coupon currently applied.')
    end

    it 'When I enter in a coupon code it shows my discounted total' do
      visit item_path(@ogre)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'

      visit '/cart'

      fill_in :coupon_code, with: 'BF2019'
      click_button 'Submit'

      expect(page).to have_content('BF2019 coupon applied!')
      expect(page).to have_content('BF2019 coupon currently applied.')

      expect(current_path).to eq('/cart')

      expect(page).to have_content('Subtotal: $120.00')
      expect(page).to have_content('Total Discounts: -$4.00')
      expect(page).to have_content('Grand Total: $116.00')
    end

    it 'The discounted total changes when I enter in a new eligible code' do
      visit item_path(@ogre)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'
      visit item_path(@hippo)
      click_button 'Add to Cart'

      visit '/cart'

      fill_in :coupon_code, with: 'BF2019'
      click_button 'Submit'

      expect(page).to have_content('BF2019 coupon applied!')
      expect(page).to have_content('BF2019 coupon currently applied.')

      expect(current_path).to eq('/cart')

      expect(page).to have_content('Subtotal: $120.00')
      expect(page).to have_content('Total Discounts: -$4.00')
      expect(page).to have_content('Grand Total: $116.00')

      fill_in :coupon_code, with: 'Mega10'
      click_button 'Submit'

      expect(page).to have_content('Mega10 coupon applied!')
      expect(page).to have_content('Mega10 coupon currently applied.')

      expect(page).to have_content('Subtotal: $120.00')
      expect(page).to have_content('Total Discounts: -$10.00')
      expect(page).to have_content('Grand Total: $110.00')
    end

    it "I do not see a discounted total when I enter in a coupon code for items that do not apply" do
      visit item_path(@ogre)
      click_button 'Add to Cart'

      visit '/cart'

      fill_in :coupon_code, with: 'Mega10'
      click_button 'Submit'

      expect(page).to have_content('This coupon does not exist or is not valid for these items.')

      expect(page).to have_content('Subtotal: $20.00')
      expect(page).to have_content('Grand Total: $20.00')

      expect(page).to_not have_content('Total Discounts:')
    end
  end
end
