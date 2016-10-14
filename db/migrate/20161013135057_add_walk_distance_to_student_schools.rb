class AddWalkDistanceToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :walk_distance, :string
  end
end
