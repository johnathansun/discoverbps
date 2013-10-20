class AddGradeLevelsToPreferences < ActiveRecord::Migration
  def change
  	add_column :preferences, :grade_k0, :boolean, default: false
  	add_column :preferences, :grade_k1, :boolean, default: false
  	add_column :preferences, :grade_k2, :boolean, default: false
  	add_column :preferences, :grade_1, :boolean, default: false
  	add_column :preferences, :grade_2, :boolean, default: false
  	add_column :preferences, :grade_3, :boolean, default: false
  	add_column :preferences, :grade_4, :boolean, default: false
  	add_column :preferences, :grade_5, :boolean, default: false
  	add_column :preferences, :grade_6, :boolean, default: false
  	add_column :preferences, :grade_7, :boolean, default: false
  	add_column :preferences, :grade_8, :boolean, default: false
  	add_column :preferences, :grade_9, :boolean, default: false
  	add_column :preferences, :grade_10, :boolean, default: false
  	add_column :preferences, :grade_11, :boolean, default: false
  	add_column :preferences, :grade_12, :boolean, default: false
  end
end
