class AddSpedAndEllAttributesToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :sped_cluster, :string
    add_column :student_schools, :sped_description, :text
    add_column :student_schools, :ell_cluster, :string
    add_column :student_schools, :ell_description, :text
  end
end
