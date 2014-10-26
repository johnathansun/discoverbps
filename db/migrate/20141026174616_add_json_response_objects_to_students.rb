class AddJsonResponseObjectsToStudents < ActiveRecord::Migration
  def change
    add_column :students, :home_schools_json, :text
    add_column :students, :zone_schools_json, :text
    add_column :students, :ell_schools_json, :text
    add_column :students, :sped_schools_json, :text
  end
end
