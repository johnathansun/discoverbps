class School < ActiveRecord::Base
	extend FriendlyId
	friendly_id :name, use: :slugged

	attr_protected
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
end
