class AddAddressVerifiedToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :address_verified, :boolean, default: false
  end
end
