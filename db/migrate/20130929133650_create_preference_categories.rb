class CreatePreferenceCategories < ActiveRecord::Migration
  def change
    create_table :preference_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
