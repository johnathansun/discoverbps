class CreateStudentSchools < ActiveRecord::Migration
  def change
    create_table :student_schools do |t|
      t.integer :student_id
      t.integer :school_id
      t.string :tier
      t.string :walk_zone_eligibility
      t.string :transportation_eligibility
      t.string :distance
      t.string :walk_time
      t.string :drive_time
      t.integer :sort_order

      t.timestamps
    end
    add_index :student_schools, :school_id
    add_index :student_schools, :student_id
  end
end
