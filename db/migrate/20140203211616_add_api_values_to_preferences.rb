class AddApiValuesToPreferences < ActiveRecord::Migration
  def change
  	add_column :preferences, :api_table_name, :string
  	add_column :preferences, :api_table_key, :string
  	add_column :preferences, :api_table_value, :string
  end
end
