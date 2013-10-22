class AddXAndYCoordinatesToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :x_coordinate, :float
  	add_column :students, :y_coordinate, :float
  end
end
