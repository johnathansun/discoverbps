require 'json'

root_url        = "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/"
school_year     = "2014"

task :update_schools => [
  :update_basic_info,
  :update_awards,
  :update_description,
  :update_facilities,
  :update_grades,
  :update_hours,
  :update_languages,
  :update_partners,
  :update_photos,
  :update_sports
]

task :update_basic_info => :environment do
  puts "===> Updating each school's basic info from API..."
  SchoolData.update_basic_info!
end

task :update_awards => :environment do
  puts "===> Updating each school's awards from API..."
  SchoolData.update_awards!
end

task :update_description => :environment do
  puts "===> Updating each school's descriptions from API..."
  SchoolData.update_descriptions!
end

task :update_facilities => :environment do
  puts "===> Updating each school's facilities from API..."
  SchoolData.update_facilities!
end

task :update_grades => :environment do
  puts "===> Updating each school's grades from API..."
  SchoolData.update_grades!
end

task :update_hours => :environment do
  puts "===> Updating each school's hours from API..."
  SchoolData.update_hours!
end

task :update_languages => :environment do
  puts "===> Updating each school's languages from API..."
  SchoolData.update_languages!
end

task :update_partners => :environment do
  puts "===> Updating each school's partners from API..."
  SchoolData.update_partners!
end

task :update_photos => :environment do
  puts "===> Updating each school's photos from API..."
  SchoolData.update_photos!
end

task :update_sports => :environment do
  puts "===> Updating each school's sports from API..."
  SchoolData.update_sports!
end
