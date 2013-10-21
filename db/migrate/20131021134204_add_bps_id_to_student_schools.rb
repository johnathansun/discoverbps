class AddBpsIdToStudentSchools < ActiveRecord::Migration
  def change
  	add_column :student_schools, :bps_id, :string
  	add_index :student_schools, :bps_id
  end
end
