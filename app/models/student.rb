class Student < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
	has_and_belongs_to_many :preferences, uniq: true, after_add: :count_preferences, after_remove: :count_preferences
	has_many :student_schools, uniq: true
  has_many :schools, through: :student_schools

  scope :verified, where(address_verified: true)
  
  attr_accessible :first_name, :last_name, :grade_level, :iep, :primary_language, :session_id, :sibling_school_ids, :sibling_school_names, :street_name, :street_number, :neighborhood, :zipcode, :latitude, :longitude, :user_id, :preference_ids, :school_ids, :iep_needs, :ell_needs, :schools_last_updated_at, :x_coordinate, :y_coordinate, :address_verified, :geo_code, :preferences_count
  
  serialize :sibling_school_names
  serialize :sibling_school_ids

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

  def full_name
    "#{first_name.try(:humanize)} #{last_name.try(:humanize)}"
  end

  def full_address
    "#{street_number} #{street_name} #{zipcode}"
  end

  def created_at_date
    created_at.to_date
  end

private

  def format_grade_level
    self.grade_level = self.grade_level.strip.upcase if self.grade_level.present?
  end

  def count_preferences
    self.update_column(:preferences_count, self.preferences.count)
  end
end
