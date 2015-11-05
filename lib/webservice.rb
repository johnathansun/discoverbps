module Webservice

	# The following methods connect to endpoints on the BPS webservice. See:
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/help


	##### ADDRESS MATCHES #####

	def self.address_matches(street_number, street_name, zipcode)
		endpoint = "AddressMatches"
		params = {streetnumber: street_number, street: street_name, zipcode: zipcode}.to_param
		extract_from_array = false
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, nil)
	end


	##### HOME SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/schools.svc/HomeSchools?SchYear=2014&Grade=06&AddressID=68051&IsAwc=true&SiblingSchList=

	def self.home_schools(grade_level, addressid, awc, sibling_ids=[])
		endpoint = "HomeSchools"
		sibling_school_ids = sibling_ids.try(:compact).try(:join, ",")
		params = {schyear: SCHOOL_YEAR, grade: grade_level, addressid: addressid, isawc: awc, siblingschlist: sibling_school_ids}.to_param
		extract_from_array = false
		puts "****************** Getting Home schools from webservice with (#{grade_level}, #{addressid}, #{awc}, #{sibling_ids})"
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, nil)
	end


	##### ZONE SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10/schools.svc/GetSchoolInterestList?SchoolYear=2014-2015&Grade=03&ZipCode=02124&Geo=060&X=774444.562683105&Y=2961259.5579834&SiblingSchList=
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/ZoneSchools?SchYear=2014&Grade=07&SiblingSchList=&AddressID=68051

	def self.zone_schools(grade_level, addressid, sibling_ids=[])
		endpoint = "ZoneSchools"
		sibling_school_ids = sibling_ids.try(:compact).try(:join, ",")
		params = {schyear: SCHOOL_YEAR, grade: grade_level, addressid: addressid, siblingschlist: sibling_school_ids}.to_param
		extract_from_array = false
		puts "****************** Getting Zone schools from webservice with (#{grade_level}, #{addressid}, #{sibling_ids})"
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, nil)
	end

	##### ELL SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/ELLList?schyear=2014&addressID=68051&gradeLevel=07

	def self.ell_schools(grade_level, addressid, language)
		endpoint = "ELLSchools"
		params = {schyear: SCHOOL_YEAR, gradelevel: grade_level, addressid: addressid, language: language}.to_param
		extract_from_array = false
		puts "****************** Getting ELL schools from webservice with (#{grade_level}, #{addressid}, #{language})"
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, nil)
	end


	##### SPED SCHOOLS #####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/Schools.svc/SPEDList?schyear=2014&addressID=68051&gradeLevel=07

	def self.sped_schools(grade_level, addressid)
		endpoint = "SPEDSchools"
		params = {schyear: SCHOOL_YEAR, gradelevel: grade_level, addressid: addressid}.to_param
		extract_from_array = false
		puts "****************** Getting SPED schools from webservice with (#{grade_level}, #{addressid})"
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, nil)
	end


	##### BASIC INFO #####

	def self.basic_info(bps_id)
		endpoint = "Info"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### AWARDS #####

	def self.awards(bps_id)
		endpoint = "Awards"
		params = {schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil}.to_param
		extract_from_array = false
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### DESCRIPTIONS #####

	def self.description(bps_id)
  	endpoint = "Description"
		params = {schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### FACILITIES #####

	def self.facilities(bps_id)
		endpoint = "Facilities"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### GRADE LEVELS #####

	def self.grades(bps_id)
		endpoint = "Grades"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = false
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### HOURS #####

	def self.hours(bps_id)
		endpoint  = "Hours"
		params = {schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### LANGUAGES #####

	def self.languages(bps_id)
		endpoint = "Languages"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### PARTNERS #####

	def self.partners(bps_id)
		endpoint = "Partners"
		params = {schyear: SCHOOL_YEAR, sch: bps_id, translationlanguage: nil}.to_param
		extract_from_array = false
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### PHOTOS #####

	def self.photos(bps_id)
		endpoint = "Photos"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = false
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### PREVIEW DATES #####

	def self.preview_dates(bps_id)
		endpoint = "PreviewDates"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### PROGRAMS #####

	def self.programs(bps_id)
		endpoint = "Programs"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### SPORTS #####

	def self.sports(bps_id)
		endpoint = "Sports"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### STUDENT SUPPORT #####

	def self.student_support(bps_id)
		endpoint = "StudentSupport"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	##### SURROUND CARE #####

	def self.surround_care(bps_id)
		endpoint = "SurroundCare"
		params = {schyear: SCHOOL_YEAR, sch: bps_id}.to_param
		extract_from_array = true
		api_response = self.get(endpoint, params)
		self.extract(api_response, endpoint, params, extract_from_array, bps_id)
	end

	private

	def self.get(endpoint, params)
		response = Faraday.new(url: "#{ENV['BPS_WEBSERVICE_URL']}/#{endpoint}?#{params}", ssl: {version: :SSLv3}).get
		response.body
	end

	def self.extract(api_response, endpoint, params, extract_from_array, bps_id)
		if api_response.blank?
			if bps_id.present?
				puts "********** No API response from #{endpoint} for school #{bps_id}"
				AdminMailer.api_error(endpoint, params, bps_id).deliver
			else
				puts "********** No API response from #{endpoint}"
				AdminMailer.api_error(endpoint, params, bps_id).deliver
			end
			return nil
		else
			puts "********************* #{api_response}"
			begin
				if extract_from_array == true
					# Some responses are stored as a single hash inside an array. It's easier to extract the hash from the array here
					# instead of calling .first in the views
					response = MultiJson.load(api_response, symbolize_keys: true).first
				else
					response = MultiJson.load(api_response, symbolize_keys: true)
				end
			rescue
				if bps_id.present?
					AdminMailer.api_error(endpoint, params, bps_id).deliver
					puts "********** Something went wrong when parsing #{endpoint} for school #{bps_id}"
				else
					AdminMailer.api_error(endpoint, params, bps_id).deliver
					puts "********** Something went wrong when parsing #{endpoint} endpoint"
				end
				return nil
			end
		end
	end
end
