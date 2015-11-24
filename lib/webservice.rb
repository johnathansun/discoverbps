module Webservice

	# The following methods connect to endpoints on the BPS webservice. See:
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/help


	##### ADDRESS MATCHES #####

	# {:Error=>[], :List=>[{:AddressID=>"248880", :ELLCluster=>"A", :GeoCode=>"097", :Lat=>"42.358620264041", :Lng=>"-71.0590099977779", :SPEDCluster=>"A", :SectionOfCity=>"Boston", :Street=>"Court St", :StreetNum=>"26", :X=>"775356.657775879", :Y=>"2956018.47106934", :ZipCode=>"02108", :Zone=>"N"}]}

	def self.address_matches(street_number, street_name, zipcode)
		endpoint = "AddressMatches"
		params = { streetnumber: street_number, street: street_name, zipcode: zipcode }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end


	##### STUDENT SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/schools.svc/HomeSchools?SchYear=2014&Grade=06&AddressID=68051&IsAwc=true&SiblingSchList=

	def self.student_schools(token)
		endpoint = "https://apps.mybps.org/BPSChoiceServiceStaging/api/Student"
		params = { token: token }.to_param
		response = Faraday.new(url: "#{endpoint}?#{params}", ssl: { version: :SSLv3 }).get.body
		MultiJson.load(response, symbolize_keys: true)
	end


	##### HOME SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/schools.svc/HomeSchools?SchYear=2014&Grade=06&AddressID=68051&IsAwc=true&SiblingSchList=

	def self.home_schools(grade_level, addressid, awc, sibling_ids=[])
		endpoint = "HomeSchools"
		sibling_school_ids = sibling_ids.try(:compact).try(:join, ",")
		params = { schyear: SCHOOL_YEAR, grade: grade_level, addressid: addressid, isawc: awc, siblingschlist: sibling_school_ids }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end


	##### ZONE SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10/schools.svc/GetSchoolInterestList?SchoolYear=2014-2015&Grade=03&ZipCode=02124&Geo=060&X=774444.562683105&Y=2961259.5579834&SiblingSchList=
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/ZoneSchools?SchYear=2014&Grade=07&SiblingSchList=&AddressID=68051

	def self.zone_schools(grade_level, addressid, sibling_ids=[])
		endpoint = "ZoneSchools"
		sibling_school_ids = sibling_ids.try(:compact).try(:join, ",")
		params = { schyear: SCHOOL_YEAR, grade: grade_level, addressid: addressid, siblingschlist: sibling_school_ids }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end

	##### ELL SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/ELLList?schyear=2014&addressID=68051&gradeLevel=07

	def self.ell_schools(grade_level, addressid, language)
		endpoint = "ELLSchools"
		params = { schyear: SCHOOL_YEAR, gradelevel: grade_level, addressid: addressid, language: language }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end


	##### SPED SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/SPEDList?schyear=2014&addressID=68051&gradeLevel=07

	def self.sped_schools(grade_level, addressid)
		endpoint = "SPEDSchools"
		params = { schyear: SCHOOL_YEAR, gradelevel: grade_level, addressid: addressid }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, nil)
	end


	##### BASIC INFO #####

	def self.basic_info(bps_id)
		endpoint = "Info"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "basic_info")
	end

	##### AWARDS #####

	def self.awards(bps_id)
		endpoint = "Awards"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "awards")
	end

	##### DESCRIPTIONS #####

	def self.description(bps_id)
  	endpoint = "Description"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "descriptions")
	end

	##### FACILITIES #####

	def self.facilities(bps_id)
		endpoint = "Facilities"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "facilities")
	end

	##### GRADE LEVELS #####

	def self.grades(bps_id)
		endpoint = "Grades"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "grades")
	end

	##### HOURS #####

	def self.hours(bps_id)
		endpoint  = "Hours"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "hours")
	end

	##### LANGUAGES #####

	def self.languages(bps_id)
		endpoint = "Languages"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "languages")
	end

	##### PARTNERS #####

	def self.partners(bps_id)
		endpoint = "Partners"
		params = { schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "partners")
	end

	##### PHOTOS #####

	def self.photos(bps_id)
		endpoint = "Photos"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = false
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "photos")
	end

	##### PREVIEW DATES #####

	def self.preview_dates(bps_id)
		endpoint = "PreviewDates"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "preview_dates")
	end

	##### PROGRAMS #####

	def self.programs(bps_id)
		endpoint = "Programs"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "programs")
	end

	##### SPORTS #####

	def self.sports(bps_id)
		endpoint = "Sports"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "sports")
	end

	##### STUDENT SUPPORT #####

	def self.student_support(bps_id)
		endpoint = "StudentSupport"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "student_support")
	end

	##### SURROUND CARE #####

	def self.surround_care(bps_id)
		endpoint = "SurroundCare"
		params = { schyear: SCHOOL_YEAR, sch: bps_id }.to_param
		extract_from_array = true
		response = self.get(endpoint, params)
		self.extract(response, endpoint, params, extract_from_array, bps_id, "surround_care")
	end

	private

	def self.get(endpoint, params)
		response = Faraday.new(url: "#{ENV['BPS_WEBSERVICE_URL']}/#{endpoint}?#{params}", ssl: { version: :SSLv3 }).get
		response.body
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
