class AddHomePageAndSchoolsPageToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :home_page, :boolean, default: true
  	add_column :notifications, :schools_page, :boolean, default: true
  end
end
