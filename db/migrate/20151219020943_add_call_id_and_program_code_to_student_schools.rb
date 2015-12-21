class AddCallIdAndProgramCodeToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :call_id, :string
    add_column :student_schools, :program_code, :string
  end
end
