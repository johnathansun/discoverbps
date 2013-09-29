class AddSortOrderToPreferences < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :sort_order, :integer
  	add_column :preferences, :sort_order, :integer
  end
end
