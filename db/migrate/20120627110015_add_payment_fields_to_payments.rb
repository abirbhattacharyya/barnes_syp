class AddPaymentFieldsToPayments < ActiveRecord::Migration
  def change
  	remove_column :payments, :voucher_code
  	add_column :payments, :phone, :integer, :limit => 6
  	add_column :payments, :cc_number, :integer, :limit => 6
  	add_column :payments, :cc_type, :string
  	add_column :payments, :cc_expiry_m, :integer, :limit => 2
  	add_column :payments, :cc_expiry_y, :integer, :limit => 2
  end
end
