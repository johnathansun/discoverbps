class AddGradeLevelsToPreferenceCategories < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :grade_k0, :boolean, default: false
  	add_column :preference_categories, :grade_k1, :boolean, default: false
  	add_column :preference_categories, :grade_k2, :boolean, default: false
  	add_column :preference_categories, :grade_1, :boolean, default: false
  	add_column :preference_categories, :grade_2, :boolean, default: false
  	add_column :preference_categories, :grade_3, :boolean, default: false
  	add_column :preference_categories, :grade_4, :boolean, default: false
  	add_column :preference_categories, :grade_5, :boolean, default: false
  	add_column :preference_categories, :grade_6, :boolean, default: false
  	add_column :preference_categories, :grade_7, :boolean, default: false
  	add_column :preference_categories, :grade_8, :boolean, default: false
  	add_column :preference_categories, :grade_9, :boolean, default: false
  	add_column :preference_categories, :grade_10, :boolean, default: false
  	add_column :preference_categories, :grade_11, :boolean, default: false
  	add_column :preference_categories, :grade_12, :boolean, default: false
  end
end
