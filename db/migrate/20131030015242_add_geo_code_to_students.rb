class AddGeoCodeToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :geo_code, :string
  end
end
