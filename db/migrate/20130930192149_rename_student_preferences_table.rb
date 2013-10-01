class RenameStudentPreferencesTable < ActiveRecord::Migration
  def up
		rename_table :student_preferences, :preferences_students
  end

  def down
		rename_table :preferences_students, :student_preferences
  end
end
