class School < ActiveRecord::Base
	extend FriendlyId
	friendly_id :name, use: :slugged
	# geocoded_by :full_address

	attr_protected
	attr_accessor :tier, :transportation_eligibility, :walk_zone_eligibility, :walk_time, :drive_time, :distance
	# attr_accessible :name, :bps_id, :api_basic_info, :api_awards, :api_calendar, :api_description, :api_extra_curricular, :api_facilities, :api_grades, :api_hours, :api_languages, :api_partners, :api_photos

	serialize :api_basic_info     
	serialize :api_awards
	serialize :api_calendar
	serialize :api_description
	serialize :api_extra_curricular
	serialize :api_facilities
	serialize :api_grades
	serialize :api_hours
	serialize :api_languages
	serialize :api_partners
	serialize :api_photos

	# after_validation :geocode

	def full_address
		"#{api_basic_info[0][:campus1address1]} #{api_basic_info[0][:campus1city]} #{api_basic_info[0][:campus1zip]}"
	end

	# turn api_grades into an array
	def grade_levels
		if api_grades.present? && api_grades[0][:grade].present?
			grades = ['K0', 'K1', 'K2', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
			start_grade = api_grades[0][:grade].upcase.match(/^../).to_s
			end_grade = api_grades[0][:grade].upcase.match(/..$/).to_s
			if start_grade.present? && end_grade.present?
				start_grade_index = grades.index(start_grade)
				end_grade_index = grades.index(end_grade)
				grades[start_grade_index..end_grade_index]
			end
		end
	end

	def facilities_present?
		if api_facilities.present?
			facilities = api_facilities[0]
			if facilities[:hasartroom] == 'True' || facilities[:hasathleticfield] == 'True' || facilities[:hasauditorium] == 'True' || facilities[:hascafeteria] == 'True' || facilities[:hascomputerlab] == 'True' || facilities[:hasgymnasium] == 'True' || facilities[:haslibrary] == 'True' || facilities[:hasmusicroom] == 'True' || facilities[:hasoutdoorclassroom] == 'True' || facilities[:hasplayground] == 'True' || facilities[:haspool] == 'True' || facilities[:hassciencelab] == 'True'
				return true
			else
				return false
			end
		else
			return false
		end
	end

	def fulltime_nurse?
		if api_basic_info.present?
			if api_basic_info[0][:ishasfulltimenurse] == 'True'
				return true
			else
				return false
			end
		else
			return false
		end
	end

	def uniform_policy?
		if api_description.present?
			if api_description[0][:uniformpolicy].blank? || api_description[0][:uniformpolicy] == 'No Uniform' || api_description[0][:uniformpolicy] == 'Not Specified'
				return false
			else
				return true
			end
		else
			return false
		end
	end
end
