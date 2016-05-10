class CreateRegistrationDates < ActiveRecord::Migration
  def change
    create_table :registration_dates do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
