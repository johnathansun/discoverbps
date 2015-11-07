class RenameLastSyncedToLastSyncOnSchools < ActiveRecord::Migration
  def up
    rename_column :schools, :last_synced, :last_sync
  end

  def down
    rename_column :schools, :last_sync, :last_synced
  end
end
