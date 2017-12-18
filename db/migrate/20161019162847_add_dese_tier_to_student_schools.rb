class AddDeseTierToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :dese_tier, :string    
  end
end
