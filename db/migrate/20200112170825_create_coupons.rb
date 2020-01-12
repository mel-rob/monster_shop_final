class CreateCoupons < ActiveRecord::Migration[5.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.decimal :percentage_off
      t.string :code
      t.boolean :active?, default: true

      t.references :merchant, foreign_key: true

      t.timestamps
    end
  end
end
