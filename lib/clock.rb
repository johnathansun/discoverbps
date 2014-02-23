require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../../config/environment', __FILE__)

require 'clockwork'
include Clockwork

handler do |job|
  puts "Running #{job}"
end

# 9 UTC = 3am EST and 12am PST
every(1.day, 'Update school basic info', :at => '20:00') { SchoolData.delay.update_basic_info! }
every(1.day, 'Update school awards', :at => '20:00') { SchoolData.delay.update_awards! }
every(1.day, 'Update school descriptions', :at => '20:00') { SchoolData.delay.update_descriptions! }
every(1.day, 'Update school facilities', :at => '20:00') { SchoolData.delay.update_facilities! }
every(1.day, 'Update school grades', :at => '20:00') { SchoolData.delay.update_grades! }
every(1.day, 'Update school hours', :at => '20:00') { SchoolData.delay.update_hours! }
every(1.day, 'Update school languages', :at => '20:00') { SchoolData.delay.update_languages! }
every(1.day, 'Update school partners', :at => '20:00') { SchoolData.delay.update_partners! }
every(1.day, 'Update school photos', :at => '20:00') { SchoolData.delay.update_photos! }
every(1.day, 'Update school sports', :at => '20:00') { SchoolData.delay.update_sports! }	