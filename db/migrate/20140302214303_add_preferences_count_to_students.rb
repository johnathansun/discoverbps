class AddPreferencesCountToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :preferences_count, :integer
  end
end
