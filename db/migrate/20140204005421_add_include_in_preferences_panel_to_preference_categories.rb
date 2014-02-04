class AddIncludeInPreferencesPanelToPreferenceCategories < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :include_in_preferences_panel, :boolean, default: true
  end
end
