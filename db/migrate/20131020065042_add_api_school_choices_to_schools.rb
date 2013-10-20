class AddApiSchoolChoicesToSchools < ActiveRecord::Migration
  def change
  	add_column :students, :api_school_choices, :text
  	add_column :students, :api_school_choices_created_at, :time
  end
end
