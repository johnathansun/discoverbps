class AddApiOtherProgramsToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :api_other_programs, :text
  end
end
