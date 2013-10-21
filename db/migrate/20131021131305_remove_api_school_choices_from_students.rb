class RemoveApiSchoolChoicesFromStudents < ActiveRecord::Migration
  def up
  	remove_column :students, :api_school_choices
  end

  def down
  	add_column :students, :api_school_choices, :text
  end
end
