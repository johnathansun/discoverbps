class Student < ActiveRecord::Base
  belongs_to :user
  has_many :school_rankings
	has_and_belongs_to_many :preferences, uniq: true
	has_and_belongs_to_many :schools, uniq: true
  
  attr_accessible :first_name, :last_name, :grade_level, :iep, :primary_language, :session_id, :sibling_school_id, :sibling_school_name, :street_name, :street_number, :neighborhood, :zipcode, :latitude, :longitude, :user_id, :preference_ids, :school_ids, :iep_needs, :ell_needs, :api_school_choices, :api_school_choices_created_at
  
  validates :street_number, :street_name, :zipcode, :grade_level, presence: true

  serialize :api_school_choices     

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
