class RemoveZoneSchoolsFromStudents < ActiveRecord::Migration
  def change
    remove_column :students, :zone_schools_json
  end
end
