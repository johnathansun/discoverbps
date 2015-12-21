class AddChoiceRankToStudentSchools < ActiveRecord::Migration
  def change
    add_column :student_schools, :choice_rank, :integer, default: nil
  end
end
