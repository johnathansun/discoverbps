class AddStarredToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :starred, :boolean, default: false
  end
end
