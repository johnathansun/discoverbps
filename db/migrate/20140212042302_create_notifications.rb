class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :message
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end
end
