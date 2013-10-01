class Student < ActiveRecord::Base
	has_and_belongs_to_many :preferences
	has_and_belongs_to_many :schools
  
  attr_accessible :first_name, :grade_level, :iep, :last_name, :primary_language, :session_id, :sibling_school_id, :sibling_school_name, :street_name, :street_number, :user_id, :zipcode, :preference_ids, :school_ids
  validates :street_number, :street_name, :zipcode, :first_name, :last_name, :grade_level, presence: true
end
