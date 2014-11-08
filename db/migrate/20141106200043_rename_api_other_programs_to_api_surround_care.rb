class RenameApiOtherProgramsToApiSurroundCare < ActiveRecord::Migration
  def up
    rename_column :schools, :api_other_programs, :api_surround_care
  end

  def down
    rename_column :schools, :api_surround_care, :api_other_programs
  end
end
