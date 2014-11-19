require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

# 9 UTC = 3am EST and 12am PST
every(1.day, 'Update school basic info', :at => '6:00', :tz => 'America/New_York') 		    { SchoolData.delay(priority: 20).update_basic_info! }
every(1.day, 'Update school awards', :at => '6:01', :tz => 'America/New_York') 				    { SchoolData.delay(priority: 20).update_awards! }
every(1.day, 'Update school descriptions', :at => '6:02', :tz => 'America/New_York')      { SchoolData.delay(priority: 20).update_descriptions! }
every(1.day, 'Update school facilities', :at => '6:03', :tz => 'America/New_York') 		    { SchoolData.delay(priority: 20).update_facilities! }
every(1.day, 'Update school grades', :at => '6:04', :tz => 'America/New_York') 				    { SchoolData.delay(priority: 20).update_grades! }
every(1.day, 'Update school hours', :at => '6:05', :tz => 'America/New_York') 					  { SchoolData.delay(priority: 20).update_hours! }
every(1.day, 'Update school languages', :at => '6:06', :tz => 'America/New_York')	 		    { SchoolData.delay(priority: 20).update_languages! }
every(1.day, 'Update school partners', :at => '6:07', :tz => 'America/New_York')          { SchoolData.delay(priority: 20).update_partners! }
every(1.day, 'Update school photos', :at => '6:08', :tz => 'America/New_York') 				    { SchoolData.delay(priority: 20).update_photos! }
every(1.day, 'Update school preview dates', :at => '6:09', :tz => 'America/New_York') 		{ SchoolData.delay(priority: 20).update_preview_dates! }
every(1.day, 'Update school programs', :at => '6:10', :tz => 'America/New_York') 				  { SchoolData.delay(priority: 20).update_programs! }
every(1.day, 'Update school sports', :at => '6:11', :tz => 'America/New_York') 				    { SchoolData.delay(priority: 20).update_sports! }
every(1.day, 'Update school student support', :at => '6:12', :tz => 'America/New_York')   { SchoolData.delay(priority: 20).update_student_support! }
every(1.day, 'Update school surround care', :at => '6:13', :tz => 'America/New_York')     { SchoolData.delay(priority: 20).update_surround_care! }

every(6.hours, 'Store searches json') { StoredSearch.first_or_create.update_attributes(json: Student.order(:last_name).to_json(only: [ :grade_level, :latitude, :longitude, :zipcode, :ell_language, :sped_needs, :awc_invitation, :preferences_count  ], methods: :created_at_date)) }
