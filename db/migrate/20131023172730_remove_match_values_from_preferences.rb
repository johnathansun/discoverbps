class RemoveMatchValuesFromPreferences < ActiveRecord::Migration
  def up
  	remove_column :preferences, :match_values
  end

  def down
  	add_column :preferences, :match_values, :text
  end
end
