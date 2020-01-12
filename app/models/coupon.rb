class Coupon < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name,
                        :percentage_off,
                        :code

  validates_uniqueness_of :name
  validates_uniqueness_of :code, case_sensitive: false
end
