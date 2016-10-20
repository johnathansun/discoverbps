require 'json'

task :import_schools => :environment do
  root_url = "https://apps.mybps.org/WebServiceDiscoverBPSv1.10Staging/Schools.svc/"
  school_year = "2016"

  school_list_endpoint = "SchoolList?schyear=#{school_year}"

  school_list_url = "#{root_url}#{school_list_endpoint}"

  puts "===> Fetching schools..."
  api_schools = MultiJson.load(Faraday.new(
    :url => school_list_url,
    :ssl => {:verify => false}).get.body, :symbolize_keys => true)
  #version => :SSLv3

  puts "===> Populating local DB with schools..."
  api_schools.each {|x| School.create(bps_id: x[:sch],
    api_basic_info: x, name: x[:schname_23], latitude: x[:Latitude],
    longitude: x[:Longitude])}

end