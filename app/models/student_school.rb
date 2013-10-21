class StudentSchool < ActiveRecord::Base
	include RankedModel
	ranks :sort_order, :with_same => :student_id 

	belongs_to :school
	belongs_to :student
  attr_accessible :distance, :drive_time, :school_id, :student_id, :tier, :transportation_eligibility, :walk_time, :walk_zone_eligibility, :sort_order_position, :bps_id, :ranked
end
