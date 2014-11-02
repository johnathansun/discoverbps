class AddApiProgramsToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :api_programs, :text
  end
end
