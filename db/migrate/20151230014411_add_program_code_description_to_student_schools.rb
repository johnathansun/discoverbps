class AddProgramCodeDescriptionToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :program_code_description, :text
  end
end
