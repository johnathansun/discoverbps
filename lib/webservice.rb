module Webservice

	# The following methods connect to endpoints on the BPS webservice. See:
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/help


	##### CHOICE SCHOOLS #####

	# {:Token=>"DC74E778-00E3-749A-56E3-001D7EAD42D0", :FirstName=>"Mario", :LastName=>"Haley", :StudentName=>"Haley, MarioStacey", :Grade=>"11", :AddressID=>348690,
	# :Street=>"GARDNER ST", :Streetno=>"4", :City=>"Allston", :ZipCode=>"02134", :State=>"MA",
	# :GeoCode=>"801", :Latitude=>"42.3536288141557", :Longitude=>"-71.1316370974287", :X=>"755735.124511719", :Y=>"2954106.35369873"}

	def self.get_student(token)
		endpoint = "#{ENV['WEBSERVICE_STAGING_URL']}/student/getstudent"
		params = { token: token, schyear: "2015" }.to_param
		response = Faraday.new(url: "#{endpoint}?#{params}", ssl: { version: :SSLv3 }).get.body
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.generate_passcode(token, email)
		endpoint = "#{ENV['WEBSERVICE_STAGING_URL']}/student/generatepasscode"
		response = self.post(endpoint, { studentToken: token, contactEmail: email }).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.generate_session_token(token, passcode)
		endpoint = "#{ENV['WEBSERVICE_STAGING_URL']}/authenticate/getsessiontoken"
		response = self.post(endpoint, { studentToken: token, passCode: passcode }).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.get_choice_schools(session_token)
		endpoint = "#{ENV['WEBSERVICE_STAGING_URL']}/student/getchoiceschools"
		params = { sessionToken: session_token, schyear: "2015" }.to_param
		response = Faraday.new(url: "#{endpoint}?#{params}", ssl: { version: :SSLv3 }).get.body
		MultiJson.load(response, symbolize_keys: true)
	end

	##### SUBMIT RANKED CHOICE LIST #####

	def self.save_choice_rank(session_token, schools)
		endpoint = "#{ENV['WEBSERVICE_STAGING_URL']}/student/savechoicerank"
		payload = { sessionToken: session_token }.merge(schools)
		response = self.post(endpoint, payload).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	##### ADDRESS MATCHES #####

	# {:Error=>[], :List=>[{:AddressID=>"248880", :ELLCluster=>"A", :GeoCode=>"097", :Lat=>"42.358620264041", :Lng=>"-71.0590099977779", :SPEDCluster=>"A", :SectionOfCity=>"Boston", :Street=>"Court St", :StreetNum=>"26", :X=>"775356.657775879", :Y=>"2956018.47106934", :ZipCode=>"02108", :Zone=>"N"}]}

	def self.get_address_matches(street_number, street_name, zipcode)
		endpoint = "#{ENV['WEBSERVICE_URL']}/AddressMatches"
		params = { streetnumber: street_number, street: street_name, zipcode: zipcode }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end

	##### HOME SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/schools.svc/HomeSchools?SchYear=2014&Grade=06&AddressID=68051&IsAwc=true&SiblingSchList=

	def self.get_home_schools(grade_level, addressid, awc, sibling_ids=[])
		endpoint = "#{ENV['WEBSERVICE_URL']}/HomeSchools"
		sibling_school_ids = sibling_ids.try(:compact).try(:join, ",")
		params = { schyear: SCHOOL_YEAR, grade: grade_level, addressid: addressid, isawc: awc, siblingschlist: sibling_school_ids }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end


	##### ZONE SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10/schools.svc/GetSchoolInterestList?SchoolYear=2014-2015&Grade=03&ZipCode=02124&Geo=060&X=774444.562683105&Y=2961259.5579834&SiblingSchList=
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/ZoneSchools?SchYear=2014&Grade=07&SiblingSchList=&AddressID=68051

	def self.get_zone_schools(grade_level, addressid, sibling_ids=[])
		endpoint = "#{ENV['WEBSERVICE_URL']}/ZoneSchools"
		sibling_school_ids = sibling_ids.try(:compact).try(:join, ",")
		params = { schyear: SCHOOL_YEAR, grade: grade_level, addressid: addressid, siblingschlist: sibling_school_ids }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end

	##### ELL SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/ELLList?schyear=2014&addressID=68051&gradeLevel=07

	def self.get_ell_schools(grade_level, addressid, language)
		endpoint = "#{ENV['WEBSERVICE_URL']}/ELLSchools"
		params = { schyear: SCHOOL_YEAR, gradelevel: grade_level, addressid: addressid, language: language }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end


	##### SPED SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/SPEDList?schyear=2014&addressID=68051&gradeLevel=07

	def self.get_sped_schools(grade_level, addressid)
		endpoint = "#{ENV['WEBSERVICE_URL']}/SPEDSchools"
		params = { schyear: SCHOOL_YEAR, gradelevel: grade_level, addressid: addressid }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end


	##### BASIC INFO #####

	def self.get_basic_info(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Info"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "basic_info")
	end

	##### AWARDS #####

	def self.get_awards(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Awards"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "awards")
	end

	##### DESCRIPTIONS #####

	def self.get_description(bps_id)
  	endpoint = "#{ENV['WEBSERVICE_URL']}/Description"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "descriptions")
	end

	##### FACILITIES #####

	def self.get_facilities(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Facilities"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "facilities")
	end

	##### GRADE LEVELS #####

	def self.get_grades(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Grades"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "grades")
	end

	##### HOURS #####

	def self.get_hours(bps_id)
		endpoint  = "#{ENV['WEBSERVICE_URL']}/Hours"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "hours")
	end

	##### LANGUAGES #####

	def self.get_languages(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Languages"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "languages")
	end

	##### PARTNERS #####

	def self.get_partners(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Partners"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "partners")
	end

	##### PHOTOS #####

	def self.get_photos(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Photos"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "photos")
	end

	##### PREVIEW DATES #####

	def self.get_preview_dates(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/PreviewDates"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "preview_dates")
	end

	##### PROGRAMS #####

	def self.get_programs(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Programs"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "programs")
	end

	##### SPORTS #####

	def self.get_sports(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/Sports"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "sports")
	end

	##### STUDENT SUPPORT #####

	def self.get_student_support(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/StudentSupport"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "student_support")
	end

	##### SURROUND CARE #####

	def self.get_surround_care(bps_id)
		endpoint = "#{ENV['WEBSERVICE_URL']}/SurroundCare"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "surround_care")
	end

	private

	def self.get(endpoint, params)
		Faraday.new(url: "#{endpoint}?#{params}", ssl: { version: :SSLv3 }).get.body
	end

	def self.post(endpoint, payload)
		Faraday.new(url: "#{endpoint}", ssl: { version: :SSLv3 }).post do |req|
		  req.headers["Content-Type"] = "application/json"
		  req.body = payload.to_json
		end
	end

	def self.extract(response, endpoint, params, extract_from_array, bps_id, sync_method=nil)
		if response.present?
			begin
				if extract_from_array == true
					# Some responses are stored as a single hash inside an array. It's easier to extract the hash from the array here
					# instead of calling .first in the views
					MultiJson.load(response, symbolize_keys: true).first
				else
					MultiJson.load(response, symbolize_keys: true)
				end
			rescue
				if bps_id.present?
					# AdminMailer.api_error(endpoint, sync_method, params, bps_id).deliver
					puts "********** Something went wrong when parsing #{endpoint} for school #{bps_id}"
				else
					# AdminMailer.api_error(endpoint, sync_method, params, bps_id).deliver
					puts "********** Something went wrong when parsing #{endpoint} endpoint"
				end
				return nil
			end
		else
			if bps_id.present?
				puts "********** No API response from #{endpoint} for school #{bps_id}"
				# AdminMailer.api_error(endpoint, sync_method, params, bps_id).deliver
			else
				puts "********** No API response from #{endpoint}"
				# AdminMailer.api_error(endpoint, sync_method, params, bps_id).deliver
			end
			return nil
		end
	end
end
