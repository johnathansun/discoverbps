class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.integer :user_id
      t.string :session_id
      t.string :first_name
      t.string :last_name
      t.string :grade_level
      t.string :street_number
      t.string :street_name
      t.string :zipcode
      t.string :iep
      t.string :primary_language
      t.string :sibling_school_name
      t.integer :sibling_school_id

      t.timestamps
    end
    add_index :students, :user_id
    add_index :students, :session_id
  end
end
