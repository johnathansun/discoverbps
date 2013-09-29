class AddMultipleStudentInfoFieldsToSearches < ActiveRecord::Migration
  def change
  	remove_column :searches, :first_name
  	remove_column :searches, :last_name
  	remove_column :searches, :grade_level
  	add_column :searches, :student_1_first_name, :string
  	add_column :searches, :student_1_last_name, :string
  	add_column :searches, :student_1_grade_level, :string
  	add_column :searches, :student_2_first_name, :string
  	add_column :searches, :student_2_last_name, :string
  	add_column :searches, :student_2_grade_level, :string
  	add_column :searches, :student_3_first_name, :string
  	add_column :searches, :student_3_last_name, :string
  	add_column :searches, :student_3_grade_level, :string
  	add_column :searches, :student_4_first_name, :string
  	add_column :searches, :student_4_last_name, :string
  	add_column :searches, :student_4_grade_level, :string
  	add_column :searches, :student_5_first_name, :string
  	add_column :searches, :student_5_last_name, :string
  	add_column :searches, :student_5_grade_level, :string
  end
end
