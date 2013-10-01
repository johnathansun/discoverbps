class AddSelectTypeToPreferenceCategories < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :select_type, :string, default: 'check_mark'
  end
end
