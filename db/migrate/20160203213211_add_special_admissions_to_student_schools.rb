class AddSpecialAdmissionsToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :special_admissions, :string
  end
end
