class CreateSchoolRankings < ActiveRecord::Migration
  def change
    create_table :school_rankings do |t|
      t.integer :user_id
      t.integer :student_id
      t.text :sorted_school_ids

      t.timestamps
    end
    add_index :school_rankings, :user_id
    add_index :school_rankings, :student_id
  end
end
