class AddSchoolTypeToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :school_type, :string
    add_index :student_schools, :school_type
  end
end
