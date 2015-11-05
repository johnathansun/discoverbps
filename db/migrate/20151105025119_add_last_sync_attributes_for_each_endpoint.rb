class AddLastSyncAttributesForEachEndpoint < ActiveRecord::Migration
  def change
    add_column :schools, :last_sync_basic_info, :datetime
    add_column :schools, :last_sync_awards, :datetime
    add_column :schools, :last_sync_descriptions, :datetime
    add_column :schools, :last_sync_facilities, :datetime
    add_column :schools, :last_sync_grades, :datetime
    add_column :schools, :last_sync_hours, :datetime
    add_column :schools, :last_sync_languages, :datetime
    add_column :schools, :last_sync_partners, :datetime
    add_column :schools, :last_sync_photos, :datetime
    add_column :schools, :last_sync_preview_dates, :datetime
    add_column :schools, :last_sync_programs, :datetime
    add_column :schools, :last_sync_sports, :datetime
    add_column :schools, :last_sync_student_support, :datetime
    add_column :schools, :last_sync_surround_care, :datetime
  end
end
