class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :offer_id
      t.integer :quantity
      t.string :voucher_code
      t.string :transaction_id
      t.string :email
      t.float :price
      t.string :first_name
      t.string :last_name
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code

      t.timestamps
    end
  end
end
