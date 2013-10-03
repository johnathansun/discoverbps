class Student < ActiveRecord::Base
	has_and_belongs_to_many :preferences, uniq: true
	has_and_belongs_to_many :schools, uniq: true
  
  attr_accessible :first_name, :grade_level, :iep, :last_name, :primary_language, :session_id, :sibling_school_id, :sibling_school_name, :street_name, :street_number, :zipcode, :latitude, :longitude, :user_id, :preference_ids, :school_ids
  validates :street_number, :street_name, :zipcode, :first_name, :last_name, :grade_level, presence: true
end
