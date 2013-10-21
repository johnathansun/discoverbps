class AddRankedToStudentSchools < ActiveRecord::Migration
  def change
  	add_column :student_schools, :ranked, :boolean, default: false
  end
end
