class School < ActiveRecord::Base
	extend FriendlyId
	friendly_id :name, use: :slugged
	# geocoded_by :full_address

	attr_protected
	attr_accessor :tier, :transportation_eligibility, :walk_zone_eligibility, :walk_time, :drive_time, :distance
	attr_accessible :api_basic_info, :api_awards, :api_description, :api_facilities, :api_grades, :api_hours, :api_languages, :api_partners, :api_photos, :name, :bps_id, :slug, :latitude, :longitude, :api_sports


	serialize :api_basic_info # Hash
	serialize :api_awards # Array
	serialize :api_description # Hash
	serialize :api_facilities # Hash
	serialize :api_grades # Array
	serialize :api_hours # Hash
	serialize :api_languages # Hash
	serialize :api_partners # Array
	serialize :api_photos # Array
	serialize :api_sports # Hash

	# after_validation :geocode
	before_save :strip_bps_id

	def full_address
		"#{api_basic_info[:campus1address1]} #{api_basic_info[:campus1city]} #{api_basic_info[:campus1zip]}"
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
			if self.send(table).present? && self.send(table).try(:[], key.to_sym).present? && self.send(table).try(:[], key.to_sym).try(:to_s) == value
				return true
			else
				return false
			end
		end
	end

	def facilities_present?
		if api_facilities.present?
			if api_facilities[:hasartroom] == 'True' || api_facilities[:hasathleticfield] == 'True' || api_facilities[:hasauditorium] == 'True' || api_facilities[:hascafeteria] == 'True' || api_facilities[:hascomputerlab] == 'True' || api_facilities[:hasgymnasium] == 'True' || api_facilities[:haslibrary] == 'True' || api_facilities[:hasmusicroom] == 'True' || api_facilities[:hasoutdoorclassroom] == 'True' || api_facilities[:hasplayground] == 'True' || api_facilities[:haspool] == 'True' || api_facilities[:hassciencelab] == 'True'
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
			if api_basic_info[:ishasfulltimenurse] == 'True'
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
			if api_description[:uniformpolicy].blank? || api_description[:uniformpolicy] == 'No Uniform' || api_description[:uniformpolicy] == 'Not Specified'
				return false
			else
				return true
			end
		else
			return false
		end
	end

	def update_from_webservice!(endpoint, params)

	end

	private

	def strip_bps_id
		self.bps_id.try(:strip!)
	end
end
