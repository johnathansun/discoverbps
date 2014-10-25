class RenameIepNeedsToSpedNeeds < ActiveRecord::Migration
  def up
    rename_column :students, :iep_needs, :sped_needs
  end

  def down
    rename_column :students, :sped_needs, :iep_needs
  end
end
