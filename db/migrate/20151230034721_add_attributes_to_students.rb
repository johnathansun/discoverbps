class AddAttributesToStudents < ActiveRecord::Migration
  def change
    add_column :students, :student_id, :string
    add_column :students, :address_id, :string
    add_column :students, :ranked, :boolean, default: false
    add_column :students, :ranked_at, :datetime
  end
end
