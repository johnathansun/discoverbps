class AddMatchValuesToPreferences < ActiveRecord::Migration
  def change
  	add_column :preferences, :match_values, :text
  end
end
