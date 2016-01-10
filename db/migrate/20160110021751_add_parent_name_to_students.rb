class AddParentNameToStudents < ActiveRecord::Migration
  def change
    add_column :students, :parent_name, :string
  end
end
