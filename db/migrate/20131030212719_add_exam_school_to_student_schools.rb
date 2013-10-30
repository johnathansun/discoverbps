class AddExamSchoolToStudentSchools < ActiveRecord::Migration
  def change
  	add_column :student_schools, :exam_school, :boolean, default: false
  end
end
