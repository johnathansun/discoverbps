class Student < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
	has_and_belongs_to_many :preferences, uniq: true
	has_many :student_schools, uniq: true
  has_many :schools, through: :student_schools
  
  attr_accessible :first_name, :last_name, :grade_level, :iep, :primary_language, :session_id, :sibling_school_id, :sibling_school_name, :street_name, :street_number, :neighborhood, :zipcode, :latitude, :longitude, :user_id, :preference_ids, :school_ids, :iep_needs, :ell_needs, :schools_last_updated_at, :x_coordinate, :y_coordinate
  
  validates :street_number, :street_name, :zipcode, :grade_level, presence: true
  validates :street_number, length: { maximum: 5 }
  validates :grade_level, inclusion: { in: %w(K0 K1 K2 1 2 3 4 5 6 7 8 9 10 11 12),
    message: "%{value} is not valid" }

  before_validation :format_grade_level

  def tab_name
  	if first_name.present?
  		first_name
  	elsif grade_level.present?
  		"Grade #{grade_level}"
  	else
  		'Anonymous'
  	end
  end

private

  def format_grade_level
    self.grade_level = self.grade_level.strip.upcase if self.grade_level.present?
  end
end
