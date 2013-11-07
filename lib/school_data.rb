module SchoolData

	def self.update_basic_info!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchool?schyear=2014&sch=#{school.bps_id}", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_basic_info: MultiJson.load(api_response, :symbolize_keys => true).try(:[], 0)) # remove hash from array
				puts "********** updating basic info for school #{school.bps_id}"
			end
		end
	end

	def self.update_awards!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolAwards?schyear=2014&sch=#{school.bps_id}&TranslationLanguage=", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_awards: MultiJson.load(api_response, :symbolize_keys => true)) 
				puts "********** updating awards for school #{school.bps_id}"
			end
		end
	end

	def self.update_descriptions!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolDescriptions?schyear=2014&sch=#{school.bps_id}&TranslationLanguage=", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_description: MultiJson.load(api_response, :symbolize_keys => true).try(:[], 0)) # remove hash from array
				puts "********** updating descriptions for school #{school.bps_id}"
			end
		end
	end

	def self.update_facilities!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolFacilities?schyear=2014&sch=#{school.bps_id}", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_facilities: MultiJson.load(api_response, :symbolize_keys => true).try(:[], 0)) # remove hash from array
				puts "********** updating facilities for school #{school.bps_id}"
			end
		end
	end

	def self.update_grades!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolGrades?schyear=2014&sch=#{school.bps_id}", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_grades: MultiJson.load(api_response, :symbolize_keys => true))
				puts "********** updating grades for school #{school.bps_id}"
			end
		end
	end

	def self.update_hours!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolHours?schyear=2014&sch=#{school.bps_id}&TranslationLanguage=", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_hours: MultiJson.load(api_response, :symbolize_keys => true).try(:[], 0)) # remove hash from array
				puts "********** updating hours for school #{school.bps_id}"
			end
		end
	end

	def self.update_languages!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolLanguages?schyear=2014&sch=#{school.bps_id}", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_languages: MultiJson.load(api_response, :symbolize_keys => true))
				puts "********** updating languages for school #{school.bps_id}"
			end
		end
	end

	def self.update_partners!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolPartners?schyear=2014&sch=#{school.bps_id}&TranslationLanguage=", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_partners: MultiJson.load(api_response, :symbolize_keys => true))
				puts "********** updating partners for school #{school.bps_id}"
			end
		end
	end

	def self.update_photos!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolPhotos?schyear=2014&sch=#{school.bps_id}", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_photos: MultiJson.load(api_response, :symbolize_keys => true))
				puts "********** updating photos for school #{school.bps_id}"
			end
		end
	end

	def self.update_sports!
		School.all.each do |school|
			api_response = Faraday.new(:url => "https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolSports?schyear=2014&sch=#{school.bps_id}", :ssl => {:version => :SSLv3}).get.body
			if api_response.present?
				school.update_attributes(api_sports: MultiJson.load(api_response, :symbolize_keys => true).try(:[], 0)) # remove hash from array
				puts "********** updating sports for school #{school.bps_id}"
			end
		end
	end
end