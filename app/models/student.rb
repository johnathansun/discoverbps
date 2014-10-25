class Student < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :user
	has_and_belongs_to_many :preferences, uniq: true, after_add: :count_preferences, after_remove: :count_preferences
	has_many :student_schools, uniq: true
  has_many :schools, through: :student_schools
  has_many :home_schools, through: :student_schools, conditions: 'school_type = home_schools'
  has_many :zone_schools, through: :student_schools, conditions: 'school_type = zone_schools'
  has_many :ell_schools, through: :student_schools, conditions: 'school_type = ell_schools'
  has_many :sped_schools, through: :student_schools, conditions: 'school_type = sped_schools'

  scope :verified, where(address_verified: true)

  attr_accessible :first_name, :last_name, :grade_level, :primary_language, :session_id, :sibling_school_ids, :sibling_school_names, :street_name, :street_number, :neighborhood, :zipcode, :latitude, :longitude, :user_id, :preference_ids, :school_ids, :sped_needs, :ell_language, :awc_invitation, :schools_last_updated_at, :x_coordinate, :y_coordinate, :address_verified, :geo_code, :preferences_count

  serialize :sibling_school_names
  serialize :sibling_school_ids

  validates :street_number, :street_name, :zipcode, :grade_level, presence: true
  validates :street_number, length: { maximum: 5 }
  validates :grade_level, inclusion: { in: %w(K0 K1 K2 1 2 3 4 5 6 7 8 9 10 11 12),
    message: "%{value} is not valid" }

  before_validation :format_grade_level
  before_save :strip_first_name, :strip_last_name, :strip_street_number, :strip_street_name, :strip_zipcode

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

  def formatted_grade_level
    grade_level.to_s.length < 2 ? ('0' + self.grade_level.try(:strip)) : self.grade_level.try(:strip)
  end


private

  def strip_first_name
    self.first_name = self.first_name.try(:strip)
  end

  def strip_last_name
    self.last_name = self.last_name.try(:strip)
  end

  def format_grade_level
    self.grade_level = self.grade_level.try(:strip).try(:upcase)
  end

  def strip_street_number
    self.street_number = self.street_number.try(:strip).try(:gsub, /\D/, '')
  end

  def strip_street_name
    self.street_name = self.street_name.try(:strip)
  end

  def strip_zipcode
    self.zipcode = self.zipcode.try(:strip)
  end

  def count_preferences(preference)
    self.update_column(:preferences_count, self.preferences.count)
  end
end
