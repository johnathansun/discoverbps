class SeedRegistrationDates < ActiveRecord::Migration
  def up
    RegistrationDate.create(name: "School Previews and School Showcases Start", start_date: Date.parse("3-12-2015"))
    RegistrationDate.create(name: "High School Showcase", start_date: Date.parse("3-12-2015"))
    RegistrationDate.create(name: "Showcase In Our Schools", start_date: Date.parse("5-12-2015"))
    RegistrationDate.create(name: "Pre-Register", start_date: Date.parse("14-12-2015"))
    RegistrationDate.create(name: "Last Names A-I", start_date: Date.parse("4-1-2016"), end_date: Date.parse("8-1-2015"))
    RegistrationDate.create(name: "Last Names J-Q", start_date: Date.parse("11-1-2016"), end_date: Date.parse("15-1-2015"))
    RegistrationDate.create(name: "Last Names R-Z", start_date: Date.parse("18-1-2016"), end_date: Date.parse("22-1-2015"))
    RegistrationDate.create(name: "All Last names", start_date: Date.parse("25-1-2016"), end_date: Date.parse("29-1-2015"))
    RegistrationDate.create(name: "All Other Grades Registration", start_date: Date.parse("3-2-2016"))
    RegistrationDate.create(name: "Assignments Mailed", start_date: Date.parse("1-3-2016"), end_date: Date.parse("1-7-2016"))
    RegistrationDate.create(name: "First Day of School", start_date: Date.parse("8-9-2016"))
    RegistrationDate.create(name: "School Choice Round 1", start_date: Date.parse("1-02-2016"), end_date: Date.parse("15-4-2016"))
    RegistrationDate.create(name: "School Choice Round 2", start_date: Date.parse("16-04-2016"), end_date: Date.parse("15-05-2016"))
  end

  def down
    RegistrationDate.destroy_all
  end
end
