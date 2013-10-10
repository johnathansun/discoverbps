class AddNeighborhoodToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :neighborhood, :string
  end
end
