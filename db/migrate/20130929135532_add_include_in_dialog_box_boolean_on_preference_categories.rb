class AddIncludeInDialogBoxBooleanOnPreferenceCategories < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :include_in_dialog_box, :boolean, default: true
  end
end
