class School < ActiveRecord::Base

	has_many :demand_data

	extend FriendlyId
	friendly_id :name, use: :slugged
	# geocoded_by :full_address

	attr_protected
	attr_accessor :tier, :transportation_eligibility, :walk_zone_eligibility, :walk_time, :drive_time, :distance
	attr_accessible :api_basic_info, :api_awards, :api_description, :api_facilities, :api_grades, :api_hours, :api_languages,
									:api_partners, :api_photos, :name, :bps_id, :slug, :latitude, :longitude, :api_sports, :api_student_support,
									:api_preview_dates, :api_programs, :api_surround_care,
									:last_sync, :last_sync_basic_info, :last_sync_awards, :last_sync_descriptions, :last_sync_facilities, :last_sync_grades,
									:last_sync_hours, :last_sync_languages, :last_sync_partners, :last_sync_photos, :last_sync_preview_dates, :last_sync_programs,
									:last_sync_sports, :last_sync_student_support, :last_sync_surround_care

	serialize :api_basic_info # Hash
	serialize :api_awards # Array
	serialize :api_description # Hash
	serialize :api_facilities # Hash
	serialize :api_grades # Array
	serialize :api_hours # Hash
	serialize :api_languages # Hash
	serialize :api_partners # Array
	serialize :api_photos # Array
	serialize :api_preview_dates # Hash
	serialize :api_programs # Hash
	serialize :api_sports # Hash
	serialize :api_student_support # Hash
	serialize :api_surround_care # Hash

	after_create :sync_school_data_callback
	# after_validation :geocode
	before_save :strip_bps_id

	def full_address
		"#{api_basic_info[:campus1address1]} #{api_basic_info[:campus1city]} #{api_basic_info[:campus1state]} #{api_basic_info[:campus1zip]} "
	end

	def map_address
		"#{api_basic_info[:campus1address1]}<br />#{api_basic_info[:campus1city]} #{api_basic_info[:campus1state]} #{api_basic_info[:campus1zip]}"
	end

	def before_care?(grade_level)
		if api_surround_care.present?
			case grade_level
			when 'K0'
				api_surround_care[:IsBeforeK0] == 'True'
			when 'K1'
				api_surround_care[:IsBeforeK1] == 'True'
			when 'K2'
				api_surround_care[:IsBeforeK2] == 'True'
			when '1'
				api_surround_care[:IsBefore1To5] == 'True'
			when '2'
				api_surround_care[:IsBefore1To5] == 'True'
			when '3'
				api_surround_care[:IsBefore1To5] == 'True'
			when '4'
				api_surround_care[:IsBefore1To5] == 'True'
			when '5'
				api_surround_care[:IsBefore1To5] == 'True'
			when '6'
				api_surround_care[:IsBefore6] == 'True'
			when '7'
				api_surround_care[:IsBefore7To8] == 'True'
			when '8'
				api_surround_care[:IsBefore7To8] == 'True'
			when '9'
				api_surround_care[:IsBefore9To12] == 'True'
			when '10'
				api_surround_care[:IsBefore9To12] == 'True'
			when '11'
				api_surround_care[:IsBefore9To12] == 'True'
			when '12'
				api_surround_care[:IsBefore9To12] == 'True'
			end
		else
			false
		end
	end

	def after_care?(grade_level)
		if api_surround_care.present?
			case grade_level
			when 'K0'
				api_surround_care[:IsAfterK0] == 'True'
			when 'K1'
				api_surround_care[:IsAfterK1] == 'True'
			when 'K2'
				api_surround_care[:IsAfterK2] == 'True'
			when '1'
				api_surround_care[:IsAfter1To5] == 'True'
			when '2'
				api_surround_care[:IsAfter1To5] == 'True'
			when '3'
				api_surround_care[:IsAfter1To5] == 'True'
			when '4'
				api_surround_care[:IsAfter1To5] == 'True'
			when '5'
				api_surround_care[:IsAfter1To5] == 'True'
			when '6'
				api_surround_care[:IsAfter6] == 'True'
			when '7'
				api_surround_care[:IsAfter7To8] == 'True'
			when '8'
				api_surround_care[:IsAfter7To8] == 'True'
			when '9'
				api_surround_care[:IsAfter9To12] == 'True'
			when '10'
				api_surround_care[:IsAfter9To12] == 'True'
			when '11'
				api_surround_care[:IsAfter9To12] == 'True'
			when '12'
				api_surround_care[:IsAfter9To12] == 'True'
			end
		else
			false
		end
	end

	# turn api_grades into an array
	def grade_levels
		if api_grades.present?
			api_grades.collect {|x| x[:grade].upcase.gsub(/^0/, '') if x[:exists] == true}.compact
		else
			[]
		end
	end

	def has_preference?(preference)
		table = preference.api_table_name
		key = preference.api_table_key
		value = preference.api_table_value

		if table.blank? || key.blank? || value.blank?
			return false
		else
			#if self.send(table).present? && self.send(table).try(:[], key.to_sym).present? && self.send(table).try(:[], key.to_sym).try(:to_s) == value
			if self.send(table).present? && self.send(table)[:GradesOffered] == value
				return true
			else
				return false
			end
		end
	end

	def facilities_present?
		if api_facilities.present?
			if 	api_facilities[:hasartroom] == 'True' ||
					api_facilities[:hasathleticfield] == 'True' ||
					api_facilities[:hasauditorium] == 'True' ||
					api_facilities[:hascafeteria] == 'True' ||
					api_facilities[:hascomputerlab] == 'True' ||
					api_facilities[:hasgymnasium] == 'True' ||
					api_facilities[:haslibrary] == 'True' ||
					api_facilities[:hasmusicroom] == 'True' ||
					api_facilities[:hasoutdoorclassroom] == 'True' ||
					api_facilities[:hasplayground] == 'True' ||
					api_facilities[:haspool] == 'True' ||
					api_facilities[:hassciencelab] == 'True'
				true
			else
				false
			end
		else
			false
		end
	end

	def student_support_present?
		if api_student_support.present?
			if api_student_support.try(:[], :HasFullTimeNurse) == 'True' ||
				api_student_support.try(:[], :HasPartTimeNurse) == 'True' ||
				api_student_support.try(:[], :HasOnlineHealthCntr) == 'True'
				api_student_support.try(:[], :HasFamilyCoord) == 'True' ||
				api_student_support.try(:[], :HasGuidanceCoord) == 'True' ||
				api_student_support.try(:[], :HasSocialWorker) == 'True'
				true
			else
				false
			end
		else
			false
		end
	end

	def uniform_policy?
		if api_description.present?
			if api_description[:uniformpolicy].blank? || api_description[:uniformpolicy] == 'No Uniform' || api_description[:uniformpolicy] == 'Not Specified'
				return false
			else
				return true
			end
		else
			return false
		end
	end

	# if a year is passed it will return applicants for that year; if no year is passed it will average the data from all years
	def applicants(grade_level, school_year=nil)
		grade = grade_level.try(:to_s).try(:strip).try(:gsub, /^0/, '').try(:upcase)
		year = school_year.try(:to_s).try(:strip).try(:gsub, /\-.*/, '').try(:strip)

		if year.present?
			self.demand_data.where(grade_level: grade, year: year).last.try(:total_applicants)
		elsif grade.present?
			self.demand_data.where(grade_level: grade).average(:total_applicants).try(:to_i)
		else
			nil
		end
	end

	# if a year is passed it will return open seats for that year; if no year is passed it will average the data from all years
	def open_seats(grade_level, school_year=nil)
		grade = grade_level.try(:to_s).try(:strip).try(:gsub, /^0/, '').try(:upcase)
		year = school_year.try(:to_s).try(:strip).try(:gsub, /\-.*/, '').try(:strip)
		if year.present?
			self.demand_data.where(grade_level: grade, year: year).last.try(:seats_before_round)
		elsif grade.present?
			self.demand_data.where(grade_level: grade).average(:seats_before_round).try(:to_i)
		else
			nil
		end
	end

	# if a year is passed it will return applicants/open seat for that year; if no year is passed it will average the data from all years
	def applicants_per_open_seat(grade_level, school_year=nil)
		grade = grade_level.try(:to_s).try(:strip).try(:gsub, /^0/, '').try(:upcase)
		year = school_year.try(:to_s).try(:strip).try(:gsub, /\-.*/, '').try(:strip)
		if grade.present?
			self.demand_data.where(grade_level: grade).average(:applicants_per_open_seat).try(:round, 2)
		elsif year.present?
			self.demand_data.where(year: year).last.try(:applicants_per_open_seat).try(:round, 2)
		elsif grade.present? && year.present?
			self.demand_data.where(grade_level: grade, year: year).last.try(:applicants_per_open_seat).try(:round, 2)
		else
			nil
		end
	end

	def total_seats(grade_level, school_year=nil)
		grade = grade_level.try(:to_s).try(:strip).try(:gsub, /^0/, '').try(:upcase)
		year = school_year.try(:to_s).try(:strip).try(:gsub, /\-.*/, '').try(:strip)

		if year.present?
			self.demand_data.where(grade_level: grade, year: year).last.try(:total_seats)
		elsif grade.present?
			self.demand_data.where(grade_level: grade).average(:total_seats).try(:to_i)
		else
			nil
		end
	end

	def self.sync_school_data!(school_id=nil)
		puts "************************ School.sync_school_data! school_id = #{school_id}"
		SchoolData.update_basic_info!(school_id)
		SchoolData.update_awards!(school_id)
		SchoolData.update_descriptions!(school_id)
		SchoolData.update_facilities!(school_id)
		SchoolData.update_grades!(school_id)
		SchoolData.update_hours!(school_id)
		SchoolData.update_languages!(school_id)
		SchoolData.update_partners!(school_id)
		SchoolData.update_photos!(school_id)
		SchoolData.update_preview_dates!(school_id)
		SchoolData.update_programs!(school_id)
		SchoolData.update_sports!(school_id)
		SchoolData.update_student_support!(school_id)
		SchoolData.update_surround_care!(school_id)
	end

	private

	def strip_bps_id
		self.bps_id.try(:strip!)
	end

	def sync_school_data_callback
		School.delay(priority: 5).sync_school_data!(self.id)
	end
end
