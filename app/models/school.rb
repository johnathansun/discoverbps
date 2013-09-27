class School < ActiveRecord::Base
  # attr_accessible :title, :body
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
