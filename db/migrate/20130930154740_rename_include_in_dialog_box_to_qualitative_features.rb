class RenameIncludeInDialogBoxToQualitativeFeatures < ActiveRecord::Migration
  def up
  	rename_column :preference_categories, :include_in_dialog_box, :qualitative_criteria
  end

  def down
  	rename_column :preference_categories, :qualitative_criteria, :include_in_dialog_box
  end
end
