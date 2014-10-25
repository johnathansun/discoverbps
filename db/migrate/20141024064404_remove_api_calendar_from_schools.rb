class RemoveApiCalendarFromSchools < ActiveRecord::Migration
  def up
    remove_column :schools, :api_calendar
  end

  def down
    add_column :schools, :api_calendar, :text
  end
end
