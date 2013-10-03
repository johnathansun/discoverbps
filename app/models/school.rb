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
end
