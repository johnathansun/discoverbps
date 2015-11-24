class AddTokenToStudents < ActiveRecord::Migration
  def change
  	add_column :students, :token, :text
  end
end
