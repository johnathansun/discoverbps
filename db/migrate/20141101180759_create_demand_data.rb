class CreateDemandData < ActiveRecord::Migration
  def change
    create_table :demand_data do |t|
      t.integer :school_id
      t.string :bps_id
      t.string :year
      t.string :grade_level
      t.integer :seats_before_round
      t.integer :seats_after_round
      t.integer :total_seats
      t.integer :first_choice_applicants
      t.integer :second_choice_applicants
      t.integer :third_choice_applicants
      t.integer :total_applicants
      t.decimal :applicants_per_open_seat, :scale => 2
      t.timestamps
    end
    add_index :demand_data, :school_id
    add_index :demand_data, :year
    add_index :demand_data, :grade_level
  end
end
