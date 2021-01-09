module Webservice

	# The following methods connect to endpoints on the BPS webservice. See:
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10Staging/Schools.svc/help


	####### CHOICE SCHOOLS FLOW #######

	def self.get_parent(token)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/student/GetParentInfo"
		params = { studentToken: token, schyear: SCHOOL_YEAR }.to_param
		response = self.get(endpoint, params)
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.generate_passcode(token, email)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/student/GeneratePasscode"
		response = self.post(endpoint, { studentToken: token, contactEmail: email }).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.generate_session_token(token, passcode)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/authenticate/GetSessionToken"
		response = self.post(endpoint, { studentToken: token, passCode: passcode }).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.get_student_homebased_choices(caseid, schoolyearcontext, clientcode, token)
		endpoint = "#{ENV['WEBAPI_REG_CHOICE_URL']}/StudentSchool/Choices"
		response =  self.postWithHeader(ENV['SERVICE_HEADER_KEY'], endpoint, { SchoolYear: schoolyearcontext, ClientCode: clientcode, Type: clientcode, CaseId: caseid, sessionToken: token }).body
		Rails.logger.info "******************** #{endpoint}"
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end


	def self.validate_session_token(token)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/authenticate/ValidateSessionToken"
		response = self.post(endpoint, { sessionToken: token }).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.get_student(token, caseid)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/student/GetStudent"
		params = { studentToken: token, schyear: SCHOOL_YEAR, caseId: caseid}.to_param
		response = self.get(endpoint, params)
		Rails.logger.info "********* GET STUDENT ********* #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.get_choice_student_and_schools(session_token)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/student/GetStudentSchoolChoices"
		response = self.post(endpoint, { sessionToken: session_token, schyear: SCHOOL_YEAR }).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end


	def self.get_ranked_choices(token, caseid)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/student/GetRankedChoices"
		Rails.logger.info "***************************caseid******#{caseid}"
		payload = { studentToken: token, caseId: caseid }
		response = self.post(endpoint, payload).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.save_ranked_choices(session_token, schools, name, clientcode, schoolyearcontext, caseid)
		endpoint = "#{ENV['WEBAPI_REG_CHOICE_URL']}/StudentSchool/RankChoices"
		payload = { sessionToken: session_token, choiceList: schools, VerificationText: name, ClientCode: clientcode, CaseId: caseid, ContextYear: schoolyearcontext }
		response = self.postWithHeader(ENV['SERVICE_HEADER_KEY'], endpoint, payload).body
		Rails.logger.info "*******ranked choice response************* #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	def self.send_ranked_email(session_token, token, caseid)
		endpoint = "#{ENV['WEBSERVICE_CHOICE_URL']}/student/SendRankedEmail"
		payload = { sessionToken: session_token, studentToken: token, caseId: caseid}
		response = self.post(endpoint, payload).body
		Rails.logger.info "******************** #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end	

	####### SCHOOLS FLOW #######

	##### ADDRESS MATCHES #####

	# {:Error=>[], :List=>[{:AddressID=>"248880", :ELLCluster=>"A", :GeoCode=>"097",
	# :Lat=>"42.358620264041", :Lng=>"-71.0590099977779", :SPEDCluster=>"A",
	# :SectionOfCity=>"Boston", :Street=>"Court St", :StreetNum=>"26",
	# :X=>"775356.657775879", :Y=>"2956018.47106934", :ZipCode=>"02108", :Zone=>"N"}]}

	def self.get_address_matches(street_number, street_name, zipcode, clientcode)
		endpoint = "#{ENV['WEBAPI_REG_CHOICE_URL']}/Students/AddressMatches"
		params = { streetnumber: street_number, street: street_name, zipcode: zipcode, ClientCode: clientcode }
		extract_from_array = false
		response = self.postWithHeader(ENV['SERVICE_HEADER_KEY'], endpoint, params).body
		Rails.logger.info "********************ADDRESS MATCHES ENDPOINT: #{endpoint}"
		Rails.logger.info "********************ADDRESS MATCHES RESPONSE: #{response}"
		response.present? ? MultiJson.load(response, symbolize_keys: true) : response
	end



	##### HOME SCHOOLS ####

	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10DEV/schools.svc/HomeSchools?SchYear=2014&Grade=06&AddressID=68051&IsAwc=true&SiblingSchList=

	def self.get_home_schools(grade_level, addressid, sibling_ids=[], clientcode, is_awc)
    endpoint = "#{ENV['WEBAPI_REG_CHOICE_URL']}/StudentSchool/Choices"
		sibling_school_ids = sibling_ids.try(:compact).try(:join, ",")
		check_is_awc = is_awc == 'Y' ? is_awc : "N"
		payload = { SchoolYear: SCHOOL_YEAR, Grade: grade_level, AddressId: addressid, Type: TYPE, IsAwc: check_is_awc, LepStatus:"N", ClientCode: clientcode, siblingsList: sibling_school_ids }
		response = self.postWithHeader(ENV['SERVICE_HEADER_KEY'], endpoint, payload).body
		Rails.logger.info "********************HOME SCHOOLS ENDPOINT: #{endpoint}"
		Rails.logger.info "********************HOME SCHOOLS RESPONSE: #{response}"
		MultiJson.load(response, symbolize_keys: true)
	end

	##### ZONE SCHOOLS #####
	# https://apps.mybps.org/WebServiceDiscoverBPSv1.10Staging/schools.svc/GetSchoolInterestList?SchoolYear=2014-2015&Grade=03&ZipCode=02124&Geo=060&X=774444.562683105&Y=2961259.5579834&SiblingSchList=
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

	def self.get_ell_schools(grade_level, addressid, language, clientcode)
		endpoint = "#{ENV['WEBAPI_REG_CHOICE_URL']}/Students/EllSchools"
		payload = { AddressId: addressid, Grade: grade_level, Language: language, ClientCode: clientcode}
		extract_from_array = false
		response = self.postWithHeader(ENV['SERVICE_HEADER_KEY'],endpoint, payload).body
		self.extract(response, endpoint, payload, extract_from_array, nil)
	end

	##### SPED SCHOOLS #####

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
		Faraday.new(url: "#{endpoint}?#{params}").get.body
	end

	def self.getWithHeader(headerKey, endpoint, params)
		con = Faraday.new

		res = con.get do |req|
			req.url "#{endpoint}?#{params}"
			req.headers["BpsToken"] = headerKey
		end
		puts "Ell Schools GetWithHeaders body: #{res.body}"
		return res.body
	end


	def self.post(endpoint, payload)
		Faraday.new(url: "#{endpoint}").post do |req|
		  req.headers["Content-Type"] = "application/json"
		  req.body = payload.to_json
		end
	end

	def self.postWithHeader(headerKey, endpoint, payload)
		Faraday.new(url: "#{endpoint}").post do |req|
		  req.headers["Content-Type"] = "application/json"
			req.options[:timeout] = 500
		  req.headers["BpsToken"] = headerKey
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
