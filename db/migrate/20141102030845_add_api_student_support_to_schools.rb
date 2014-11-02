class AddApiStudentSupportToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :api_student_support, :text
  end
end
