class AddSchoolChoicePagesToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :school_choice_pages, :boolean, default: false
  end
end
