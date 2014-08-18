module SchoolData

	##### UPDATE SCHOOL BASIC INFO #####

	def self.update_basic_info!(school_id=nil)
		endpoint = "GetSchool"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}")

			if api_response.present?
				# Use .first to store as a hash instead of a hash inside an array
      	# Alternatively, you can store as an array, but then you have to call
      	# api_basic_info.first in all partials that need to access hash values
				begin
					hash = MultiJson.load(api_response, :symbolize_keys => true).first
					school.update_attributes(name: hash[:schname_23], latitude: hash[:Latitude], longitude: hash[:Longitude], api_basic_info: hash)
				rescue
					puts "********** Something went wrong with GetSchool id #{school.bps_id}"
				else
					puts "********** Updated Basic Info for id #{school.bps_id}"					
				end
			else
				puts "********** API response not present for GetSchool with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL AWARDS #####

	def self.update_awards!(school_id=nil)
		endpoint = "GetSchoolAwards"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}&TranslationLanguage=")

			if api_response.present?
				SchoolData.extract_array(school, api_response, :api_awards, endpoint)
			else
				puts "********** API response not present for GetSchoolAwards with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL DESCRIPTIONS #####

	def self.update_descriptions!(school_id=nil)
  	endpoint = "GetSchoolDescriptions"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}&TranslationLanguage=")

			if api_response.present?
				SchoolData.extract_hash(school, api_response, :api_description, endpoint)
			else
				puts "********** API response not present for GetSchoolDescriptions with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL FACILITIES #####

	def self.update_facilities!(school_id=nil)
		endpoint = "GetSchoolFacilities"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}")

			if api_response.present?
				SchoolData.extract_hash(school, api_response, :api_facilities, endpoint)
			else
				puts "********** API response not present for GetSchoolFacilities with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL GRADES #####

	def self.update_grades!(school_id=nil)
		endpoint = "GetSchoolGrades"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}")

			if api_response.present?
				SchoolData.extract_array(school, api_response, :api_grades, endpoint)
			else
				puts "********** API response not present for GetSchoolGrades with id #{school.bps_id}"
			end
		end

	end

	##### UPDATE SCHOOL HOURS #####

	def self.update_hours!(school_id=nil)
		endpoint  = "GetSchoolHours"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}&TranslationLanguage=")
			
			if api_response.present?
				SchoolData.extract_hash(school, api_response, :api_hours, endpoint)
			else
				puts "********** API response not present for GetSchoolHours with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL LANGUAGES #####

	def self.update_languages!(school_id=nil)
		endpoint = "GetSchoolLanguages"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}")

			if api_response.present?
				SchoolData.extract_array(school, api_response, :api_languages, endpoint)
			else
				puts "********** API response not present for GetSchoolLanguages with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL PARTNERS #####

	def self.update_partners!(school_id=nil)
		endpoint = "GetSchoolPartners"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}&TranslationLanguage=")

			if api_response.present?
				SchoolData.extract_array(school, api_response, :api_partners, endpoint)
			else
				puts "********** API response not present for GetSchoolPartners with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL PHOTOS #####

	def self.update_photos!(school_id=nil)
		endpoint = "GetSchoolPhotos"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}")

			if api_response.present?
				SchoolData.extract_array(school, api_response, :api_photos, endpoint)
			else
				puts "********** API response not present for GetSchoolPhotos with id #{school.bps_id}"
			end
		end
	end

	##### UPDATE SCHOOL SPORTS #####

	def self.update_sports!(school_id=nil)
		endpoint = "GetSchoolSports"

		schools = SchoolData.schools_with_or_without_id(school_id)

		schools.each do |school|
			api_response = SchoolData.connect_to_service("#{BPS_API_URL}/#{endpoint}?schyear=#{SCHOOL_YEAR}&sch=#{school.bps_id}")

			if api_response.present?
				SchoolData.extract_hash(school, api_response, :api_sports, endpoint)
			else
				puts "********** API response not present for GetSchoolSports with id #{school.bps_id}"
			end
		end
	end


	private

	def self.schools_with_or_without_id(school_id)
		if school_id.present?
			School.where(id: school_id)
		else
			School.all
		end
	end

	def self.connect_to_service(url)
		Faraday.new(:url => "#{url}", :ssl => {:version => :SSLv3}).get.body
	end

	def self.extract_hash(school, api_response, key, endpoint)
		# Use .first to store as a hash instead of an array with a hash as the single object.
		# The object could be stored as an array, but .first would then need to be called in all of the view partials that access this data.
  	begin
			hash = MultiJson.load(api_response, :symbolize_keys => true).first
			school.update_attributes(key => hash)
		rescue
			puts "********** Something went wrong with #{endpoint} id #{school.bps_id}"
		else
			puts "********** Updated from #{endpoint} for id #{school.bps_id}"				
		end		
	end

	def self.extract_array(school, api_response, key, endpoint)
		begin
			array = MultiJson.load(api_response, :symbolize_keys => true)
			school.update_attributes(key => array)
		rescue
			puts "********** Something went wrong with #{endpoint} id #{school.bps_id}"
		else
			puts "********** Updated from #{endpoint} for id #{school.bps_id}"		
		end
	end
end