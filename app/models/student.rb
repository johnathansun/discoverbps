class Student < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
	has_and_belongs_to_many :preferences, uniq: true, after_add: :count_preferences, after_remove: :count_preferences
	has_many :student_schools, uniq: true
  has_many :schools, through: :student_schools
  has_many :home_schools, class_name: 'StudentSchool', conditions: ['school_type = ?', 'home']
  has_many :zone_schools, class_name: 'StudentSchool', conditions: ['school_type = ?', 'zone']
  has_many :ell_schools, class_name: 'StudentSchool', conditions: ['school_type = ?', 'ell']
  has_many :sped_schools, class_name: 'StudentSchool', conditions: ['school_type = ?', 'sped']
  has_many :starred_schools, class_name: 'StudentSchool', conditions: ['starred = ?', true]

  scope :verified, where(address_verified: true)

  attr_accessible   :first_name, :last_name, :grade_level, :primary_language, :session_id, :sibling_school_ids,
                    :sibling_school_names, :street_name, :street_number, :neighborhood, :zipcode, :latitude, :longitude,
                    :addressid, :user_id, :preference_ids, :school_ids, :sped_needs, :ell_language, :awc_invitation,
                    :schools_last_updated_at, :x_coordinate, :y_coordinate, :address_verified, :geo_code, :preferences_count,
                    :home_schools_json, :zone_schools_json, :ell_schools_json, :sped_schools_json, :favorite, :step,
                    :ell_cluster, :sped_cluster, :zone

  serialize :sibling_school_names
  serialize :sibling_school_ids
  serialize :home_schools_json
  serialize :zone_schools_json
  serialize :ell_schools_json
  serialize :sped_schools_json

  validates :street_number, :street_name, :zipcode, :grade_level, presence: true
  validates :street_number, length: { maximum: 5 }
  validates :grade_level, inclusion: { in: %w(K0 K1 K2 1 2 3 4 5 6 7 8 9 10 11 12),
    message: "%{value} is not valid" }

  before_validation :format_grade_level
  before_save :strip_first_name, :strip_last_name, :strip_street_number, :strip_street_name, :strip_zipcode

  def tab_name
  	if first_name.present?
  		first_name
  	elsif grade_level.present?
  		"Grade #{grade_level}"
  	else
  		'Anonymous'
  	end
  end

  def full_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)}"
  end

  def full_address
    "#{street_number} #{street_name}, #{neighborhood} MA #{zipcode}"
  end

  def created_at_date
    created_at.to_date
  end

  def formatted_grade_level
    grade_level.to_s.length < 2 ? ('0' + self.grade_level.try(:strip)) : self.grade_level.try(:strip)
  end

  def formatted_grade_level_name
    if grade_level.to_s.length < 2
      "Grade #{grade_level}"
    else
      grade_level
    end
  end

  # SAVE SCHOOLS ON CURRENT_STUDENT

  def set_student_schools!(school_hash)
    save_student_schools!(school_hash, 'home')
  end

  def set_home_schools!
    api_schools = Webservice.home_schools(self.formatted_grade_level, self.addressid, self.awc_invitation, self.sibling_school_ids).try(:[], :List)
    save_student_schools!(api_schools, 'home')
  end

  def set_zone_schools!
    api_schools = Webservice.zone_schools(self.formatted_grade_level, self.addressid, self.sibling_school_ids).try(:[], :List)
    save_student_schools!(api_schools, 'zone')
  end

  def set_ell_schools!
    api_schools = Webservice.ell_schools(self.formatted_grade_level, self.addressid, self.ell_language)
    save_student_schools!(api_schools, 'ell')
  end

  def set_sped_schools!
    api_schools = Webservice.sped_schools(self.formatted_grade_level, self.addressid)
    save_student_schools!(api_schools, 'sped')
  end

  private

  # this method pulls a list of eligible schools from the GetSchoolChoices API,
  # saves the schools to student_schools, and fetches distance and walk/drive times from the Google Matrix API
  def save_student_schools!(api_schools, school_list_type)
    if self.longitude.present? && self.latitude.present?

      # loop through the schools returned from the API, find the matching schools in the db,
      # save the eligibility variables on student_schools, and collect the coordinates for the matrix search, below

      if api_schools.present?
        self.send("#{school_list_type}_schools".to_sym).clear
        self.update_column("#{school_list_type}_schools_json".to_sym, api_schools.to_json) rescue nil
        school_coordinates = ''
        school_ids = []

        api_schools.each do |api_school|
          school = School.where(bps_id: api_school[:SchoolID]).first

          if school.present? && !school_ids.include?(school.id)
            school_ids << school.id
            school_coordinates += "#{school.latitude},#{school.longitude}|"
            exam_school = (api_school[:IsExamSchool] == "0" ? false : true)
            self.student_schools.create(school_id: school.id, school_type: school_list_type, bps_id: api_school[:SchoolID], tier: api_school[:Tier], eligibility: api_school[:Eligibility], walk_zone_eligibility: api_school[:AssignmentWalkEligibilityStatus], transportation_eligibility: api_school[:TransEligible], distance: api_school[:StraightLineDistance], exam_school: exam_school, sped_cluster: api_school[:SPEDCluster], sped_description: api_school[:Program], ell_cluster: api_school[:ELLCluster], ell_description: api_school[:ProgramDescription])
          end
        end

        school_coordinates.gsub!(/\|$/,'')
        walk_matrix = Google.walk_times(self.latitude, self.longitude, school_coordinates)
        drive_matrix = Google.drive_times(self.latitude, self.longitude, school_coordinates)

        # save distance, walk time and drive time on the student_schools join table

        api_schools.each_with_index do |api_school, i|
          school = School.where(bps_id: api_school[:SchoolID]).first
          if school.present?
            walk_time = walk_matrix.try(:[], i).try(:[], :duration).try(:[], :text)
            drive_time = drive_matrix.try(:[], i).try(:[], :duration).try(:[], :text)

            student_school = self.student_schools.where(school_id: school.id).first_or_initialize
            student_school.update_attributes(walk_time: walk_time, drive_time: drive_time)
          end
        end

        self.update_column(:schools_last_updated_at, Time.now)
      end
    end
  end


  def strip_first_name
    self.first_name = self.first_name.try(:strip)
  end

  def strip_last_name
    self.last_name = self.last_name.try(:strip)
  end

  def format_grade_level
    self.grade_level = self.grade_level.try(:strip).try(:upcase)
  end

  def strip_street_number
    self.street_number = self.street_number.try(:strip).try(:gsub, /\D/, '')
  end

  def strip_street_name
    self.street_name = self.street_name.try(:strip)
  end

  def strip_zipcode
    self.zipcode = self.zipcode.try(:strip)
  end

  def count_preferences(preference)
    self.update_column(:preferences_count, self.preferences.count)
  end
end
