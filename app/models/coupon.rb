class Coupon < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name,
                        :percentage_off,
                        :code

end
