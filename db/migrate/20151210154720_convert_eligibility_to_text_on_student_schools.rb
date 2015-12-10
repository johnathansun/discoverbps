class ConvertEligibilityToTextOnStudentSchools < ActiveRecord::Migration
  def up
    change_column :student_schools, :eligibility, :text
  end

  def down
    change_column :student_schools, :eligibility, :string
  end
end
