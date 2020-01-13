class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :orders

  validates_presence_of :name,
                        :percentage_off,
                        :code

  validates_uniqueness_of :name, case_sensitive: false
  validates_uniqueness_of :code, case_sensitive: false

  validates_numericality_of :percentage_off, greater_than: 0
  validates_numericality_of :percentage_off, less_than_or_equal_to: 100

  def never_applied?
    orders.empty?
  end
end
