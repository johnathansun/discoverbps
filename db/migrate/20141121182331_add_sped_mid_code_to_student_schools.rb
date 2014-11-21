class AddSpedMidCodeToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :sped_mid_code, :string
  end
end
