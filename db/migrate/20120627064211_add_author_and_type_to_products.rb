class AddAuthorAndTypeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :author, :string
    add_column :products, :product_type, :integer
  end
end
