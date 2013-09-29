class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :preference_category_id
      t.string :name

      t.timestamps
    end
    add_index :preferences, :preference_category_id
  end
end
