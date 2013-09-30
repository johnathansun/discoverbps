class AddIncludeInSpecialNeedsDialogBoxToPreferenceCategories < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :include_in_special_needs_dialog_box, :boolean, default: false
  end
end
