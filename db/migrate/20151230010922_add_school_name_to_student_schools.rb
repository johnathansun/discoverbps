class AddSchoolNameToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :school_name, :string
  end
end
