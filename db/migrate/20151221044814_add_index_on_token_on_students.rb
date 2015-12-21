class AddIndexOnTokenOnStudents < ActiveRecord::Migration
  def up
    add_index :students, :token
  end

  def down
    remove_index :students, :token
  end
end
