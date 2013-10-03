class FixIndexOnJoinTables < ActiveRecord::Migration
  def up
  	drop_table :schools_students
  	drop_table :preferences_students

  	create_table :schools_students, :id => false do |t|
		  t.references :student, :null => false
		  t.references :school, :null => false
		end
		add_index :schools_students, :student_id
		add_index :schools_students, :school_id

  	create_table :preferences_students, :id => false do |t|
		  t.references :student, :null => false
		  t.references :preference, :null => false
		end
		add_index :preferences_students, :preference_id
		add_index :preferences_students, :student_id
  end

  def down

  end
end
