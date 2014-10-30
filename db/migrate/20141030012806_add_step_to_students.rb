class AddStepToStudents < ActiveRecord::Migration
  def change
    add_column :students, :step, :integer, default: 0
  end
end
