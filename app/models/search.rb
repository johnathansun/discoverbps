class Search < ActiveRecord::Base
  attr_accessible :first_name, :grade_level, :iep, :primary_language, :last_name, :session_key, :street_name, :street_number, :zipcode, :sibling_school_name, :sibling_school_id

  validates :street_number, :street_name, :zipcode, :first_name, :last_name, :grade_level, presence: true
end
