module Webservice


	##### UPDATE SCHOOL BASIC INFO #####

	def self.update_basic_info!(school_id=nil)
		endpoint = "GetSchool"

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id}.to_param
			api_response = self.get_from_service(endpoint, params)

			if api_response.present?
				# Use .first to store as a hash instead of a hash inside an array
      	# We could store it as an array, but then we'd have to call
      	# api_basic_info.first in all partials that access these values
				begin
					hash = MultiJson.load(api_response, :symbolize_keys => true).first
					school.update_attributes(name: hash[:schname_23], latitude: hash[:Latitude], longitude: hash[:Longitude], api_basic_info: hash)
				rescue
					puts "********** Something went wrong with #{endpoint} id #{school.bps_id}"
				else
					puts "********** Updated Basic Info for id #{school.bps_id}"
				end
			else
				puts "********** API response not present for #{endpoint} with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL AWARDS #####

	def self.update_awards!(school_id=nil)
		endpoint = "GetSchoolAwards"
		key = :api_awards

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id, translationlanguage: nil}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'array')
		end
	end

	##### UPDATE SCHOOL DESCRIPTIONS #####

	def self.update_descriptions!(school_id=nil)
  	endpoint = "GetSchoolDescriptions"
  	key = :api_description

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id, translationlanguage: nil}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'hash')
		end
	end

	##### UPDATE SCHOOL FACILITIES #####

	def self.update_facilities!(school_id=nil)
		endpoint = "GetSchoolFacilities"
		key = :api_facilities

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'hash')
		end
	end

	##### UPDATE SCHOOL GRADES #####

	def self.update_grades!(school_id=nil)
		endpoint = "GetSchoolGrades"
		key = :api_grades

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'array')
		end

	end

	##### UPDATE SCHOOL HOURS #####

	def self.update_hours!(school_id=nil)
		endpoint  = "GetSchoolHours"
		key = :api_hours

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id, translationlanguage: nil}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'hash')
		end
	end

	##### UPDATE SCHOOL LANGUAGES #####

	def self.update_languages!(school_id=nil)
		endpoint = "GetSchoolLanguages"
		key = :api_languages

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'array')
		end
	end

	##### UPDATE SCHOOL PARTNERS #####

	def self.update_partners!(school_id=nil)
		endpoint = "GetSchoolPartners"
		key = :api_partners

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id, translationlanguage: nil}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'array')
		end
	end

	##### UPDATE SCHOOL PHOTOS #####

	def self.update_photos!(school_id=nil)
		endpoint = "GetSchoolPhotos"
		key = :api_photos

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'array')
		end
	end

	##### UPDATE SCHOOL SPORTS #####

	def self.update_sports!(school_id=nil)
		endpoint = "GetSchoolSports"
		key = :api_sports

		schools = self.find_schools(school_id)

		schools.each do |school|
			params = {schyear: SCHOOL_YEAR, sch: school.bps_id}.to_param
			api_response = self.get_from_service(endpoint, params)
			self.extract_response(school, api_response, key, endpoint, 'hash')
		end
	end


	private

	def self.find_schools(school_id)
		if school_id.present?
			School.where(id: school_id)
		else
			School.all
		end
	end

	def self.get_from_service(endpoint, params)
		Faraday.new(:url => "#{BPS_WEBSERVICE_URL}/#{endpoint}?#{params}", :ssl => {:version => :SSLv3}).get.body
	end

	def self.extract_response(school, api_response, key, endpoint, response_type)
		if api_response.blank?
			puts "********** API response not present for #{endpoint} with id #{school.bps_id}"
		else
			begin
				if response_type == 'hash'
					# Use .first to store as a hash instead of an array with a hash as the single object.
					# The object could be stored as an array, but .first would then need to be called in all of the view partials that access this data.
					response = MultiJson.load(api_response, :symbolize_keys => true).first
				else
					response = MultiJson.load(api_response, :symbolize_keys => true)
				end
				school.update_attributes(key => response)
			rescue
				puts "********** Something went wrong with #{endpoint} id #{school.bps_id}"
			else
				puts "********** Updated from #{endpoint} for id #{school.bps_id}"
			end
		end
	end
end
