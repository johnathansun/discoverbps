class AddSessionTokenToStudents < ActiveRecord::Migration
  def change
    add_column :students, :session_token, :text
    add_index :students, :session_token
  end
end
