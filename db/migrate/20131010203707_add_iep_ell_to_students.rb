class AddIepEllToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :iep_needs, :boolean, default: false
  	add_column :students, :ell_needs, :boolean, default: false
  end
end
