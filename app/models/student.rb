class Student < ActiveRecord::Base
  belongs_to :user
  has_many :school_rankings
	has_and_belongs_to_many :preferences, uniq: true
	has_many :student_schools, uniq: true
  has_many :schools, through: :student_schools
  
  attr_accessible :first_name, :last_name, :grade_level, :iep, :primary_language, :session_id, :sibling_school_id, :sibling_school_name, :street_name, :street_number, :neighborhood, :zipcode, :latitude, :longitude, :user_id, :preference_ids, :school_ids, :iep_needs, :ell_needs, :schools_last_updated_at
  
  validates :street_number, :street_name, :zipcode, :grade_level, presence: true

  def tab_name
  	if first_name.present?
  		first_name
  	elsif grade_level.present?
  		"Grade #{grade_level}"
  	else
  		'Anonymous'
  	end
  end
end
