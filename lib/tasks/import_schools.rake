require 'json'

task :import_schools => :environment do
  root_url = "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/"
  school_year = "2014"

  school_list_endpoint = "GetSchoolList?schyear=#{school_year}"

  school_list_url = "#{root_url}#{school_list_endpoint}"

  puts "===> Fetching schools..."
  api_schools = MultiJson.load(Faraday.new(
    :url => school_list_url,
    :ssl => {:version => :SSLv3}).get.body, :symbolize_keys => true)

  puts "===> Populating local DB with schools..."
  api_schools.each {|x| School.create(bps_id: x[:sch],
    api_basic_info: x, name: x[:schname_23], latitude: x[:Latitude],
    longitude: x[:Longitude])}

end