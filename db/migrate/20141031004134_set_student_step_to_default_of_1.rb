class SetStudentStepToDefaultOf1 < ActiveRecord::Migration
  def up
    change_column_default(:students, :step, 1)
  end

  def down
    change_column_default(:students, :step, 0)
  end
end
