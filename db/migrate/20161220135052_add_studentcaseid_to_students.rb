class AddStudentcaseidToStudents < ActiveRecord::Migration
  def change
    add_column :students, :student_caseid, :string
  end
end
