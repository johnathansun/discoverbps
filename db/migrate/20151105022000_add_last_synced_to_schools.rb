class AddLastSyncedToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :last_synced, :datetime, default: nil
  end
end
