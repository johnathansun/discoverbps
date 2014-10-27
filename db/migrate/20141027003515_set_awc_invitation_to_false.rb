class SetAwcInvitationToFalse < ActiveRecord::Migration
  def up
    change_column :students, :awc_invitation, :boolean, default: false
  end

  def down
  end
end
