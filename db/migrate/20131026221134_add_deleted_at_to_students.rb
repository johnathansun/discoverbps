class AddDeletedAtToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :deleted_at, :datetime
  end
end
