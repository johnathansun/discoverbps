class AddChoiceSchoolsJsonToStudents < ActiveRecord::Migration
  def change
    add_column :students, :choice_schools_json, :text
  end
end
