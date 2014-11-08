class ClearUserIdFromStudents < ActiveRecord::Migration
  def up
    Student.all.each do |student|
      student.update_column(:old_user_id, student.user_id)
      student.update_column(:old_session_id, student.session_id)
    end
    Student.update_all(user_id: nil, session_id: nil)
  end

  def down
    Student.all.each do |student|
      student.update_column(:user_id, student.old_user_id)
      student.update_column(:session_id, student.old_session_id)
    end
    Student.update_all(old_user_id: nil, old_session_id: nil)
  end
end
