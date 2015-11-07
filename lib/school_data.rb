module SchoolData

  ##### UPDATE BASIC INFO #####

  def self.update_basic_info!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.basic_info(school.bps_id)
      if response.present?
        school.update_attributes(name: response[:schname_23], latitude: response[:Latitude], longitude: response[:Longitude], api_basic_info: response, last_sync: Time.now, last_sync_basic_info: Time.now)
      end
    end
  end

  ##### UPDATE AWARDS #####

  def self.update_awards!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.awards(school.bps_id)
      if response.present?
        school.update_attributes(api_awards: response, last_sync: Time.now, last_sync_awards: Time.now)
      end
    end
  end

  ##### UPDATE DESCRIPTIONS #####

  def self.update_descriptions!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.description(school.bps_id)
      if response.present?
        school.update_attributes(api_description: response, last_sync: Time.now, last_sync_descriptions: Time.now)
      end
    end
  end

  ##### UPDATE FACILITIES #####

  def self.update_facilities!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.facilities(school.bps_id)
      if response.present?
        school.update_attributes(api_facilities: response, last_sync: Time.now, last_sync_facilities: Time.now)
      end
    end
  end

  ##### UPDATE GRADES #####

  def self.update_grades!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.grades(school.bps_id)
      if response.present?
        school.update_attributes(api_grades: response, last_sync: Time.now, last_sync_grades: Time.now)
      end
    end
  end

  ##### UPDATE HOURS #####

  def self.update_hours!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.hours(school.bps_id)
      if response.present?
        school.update_attributes(api_hours: response, last_sync: Time.now, last_sync_hours: Time.now)
      end
    end
  end

  ##### UPDATE LANGUAGES #####

  def self.update_languages!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.languages(school.bps_id)
      if response.present?
        school.update_attributes(api_languages: response, last_sync: Time.now, last_sync_languages: Time.now)
      end
    end
  end

  ##### UPDATE PARTNERS #####

  def self.update_partners!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.partners(school.bps_id)
      if response.present?
        school.update_attributes(api_partners: response, last_sync_partners: Time.now)
      end
    end
  end

  ##### UPDATE PHOTOS #####

  def self.update_photos!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.photos(school.bps_id)
      if response.present?
        school.update_attributes(api_photos: response, last_sync: Time.now, last_sync_photos: Time.now)
      end
    end
  end

  ##### UPDATE PREVIEW DATES #####

  def self.update_preview_dates!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.preview_dates(school.bps_id)
      if response.present?
        school.update_attributes(api_preview_dates: response, last_sync: Time.now, last_sync_preview_dates: Time.now)
      end
    end
  end

  ##### UPDATE PROGRAMS #####

  def self.update_programs!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.programs(school.bps_id)
      if response.present?
        school.update_attributes(api_programs: response, last_sync: Time.now, last_sync_programs: Time.now)
      end
    end
  end

  ##### UPDATE SPORTS #####

  def self.update_sports!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.sports(school.bps_id)
      if response.present?
        school.update_attributes(api_sports: response, last_sync: Time.now, last_sync_sports: Time.now)
      end
    end
  end

  ##### UPDATE STUDENT SUPPORT #####

  def self.update_student_support!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.student_support(school.bps_id)
      if response.present?
        school.update_attributes(api_student_support: response, last_sync: Time.now, last_sync_student_support: Time.now)
      end
    end
  end

  ##### UPDATE OTHER PROGRAMS #####

  def self.update_surround_care!(school_id=nil)
    schools = self.find_schools(school_id)

    schools.each do |school|
      response = Webservice.surround_care(school.bps_id)
      if response.present?
        school.update_attributes(api_surround_care: response, last_sync: Time.now, last_sync_surround_care: Time.now)
      end
    end
  end


  private

  def self.find_schools(school_id=nil)
    if school_id.present?
      schools = School.where(id: school_id)
      puts "************************ SchoolData.find_schools school_id = #{schools.first.id}"
      return schools
    else
      School.all
    end
  end

end
