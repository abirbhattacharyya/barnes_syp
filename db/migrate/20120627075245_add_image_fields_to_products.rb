class AddImageFieldsToProducts < ActiveRecord::Migration
  def change
  	remove_attachment :products, :image
  	add_attachment :products, :front_image
  	add_attachment :products, :back_image
  end
end
