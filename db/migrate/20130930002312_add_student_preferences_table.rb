class AddStudentPreferencesTable < ActiveRecord::Migration
  def up
  	create_table :student_preferences, :id => false do |t|
		  t.references :student, :null => false
		  t.references :preference, :null => false
		end
		add_index :student_preferences, [:student_id, :preference_id], unique: true
  end

  def down
  	drop_table :student_preferences
  end
end
