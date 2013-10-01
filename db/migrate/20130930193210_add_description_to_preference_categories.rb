class AddDescriptionToPreferenceCategories < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :description, :text
  end
end
