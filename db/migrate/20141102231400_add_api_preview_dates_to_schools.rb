class AddApiPreviewDatesToSchools < ActiveRecord::Migration
  def change
    add_column :schools, :api_preview_dates, :text
  end
end
