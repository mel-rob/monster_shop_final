require 'rails_helper'

RSpec.describe Coupon do
  describe 'Relationships' do

    it {should belong_to :merchant}
  end

  describe 'Validations' do

    it {should validate_presence_of :name}
    # it {should validate_uniqueness_of :name}
    it {should validate_presence_of :percentage_off}
    it {should validate_presence_of :code}
    # it {should validate_uniqueness_of :code}
  end
end
