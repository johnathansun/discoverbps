class Search < ActiveRecord::Base
  attr_accessible :first_name, :grade_level, :iep, :language, :last_name, :session_key, :street_name, :street_number, :zipcode

  validates :first_name, :last_name, :street_name, :street_number, :zipcode, presence: true
end
