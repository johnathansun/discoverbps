class AddColumnsToStudentSchool < ActiveRecord::Migration
  def change
    add_column :student_schools, :tier_explanation, :string
    add_column :student_schools, :school_dese_accountability, :string
  end
end
