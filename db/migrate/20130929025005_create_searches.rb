class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :street_number
      t.string :street_name
      t.string :zipcode
      t.string :first_name
      t.string :last_name
      t.string :grade_level
      t.string :iep
      t.string :primary_language
      t.text :session_key

      t.timestamps
    end
  end
end
