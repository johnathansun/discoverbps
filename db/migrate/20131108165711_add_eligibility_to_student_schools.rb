class AddEligibilityToStudentSchools < ActiveRecord::Migration
  def change
  	add_column :student_schools, :eligibility, :string
  end
end
