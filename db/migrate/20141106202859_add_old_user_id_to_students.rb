class AddOldUserIdToStudents < ActiveRecord::Migration
  def change
    add_column :students, :old_user_id, :integer
    add_column :students, :old_session_id, :string
  end
end
