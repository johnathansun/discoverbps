class AddAddressidToStudents < ActiveRecord::Migration
  def change
    add_column :students, :addressid, :string
  end
end
