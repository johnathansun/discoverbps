class AddAwcInvitationToStudents < ActiveRecord::Migration
  def change
    add_column :students, :awc_invitation, :boolean
  end
end
