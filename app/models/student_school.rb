class StudentSchool < ActiveRecord::Base
	include RankedModel
	ranks :sort_order, :with_same => :student_id

	belongs_to :school
	belongs_to :student
  attr_accessible :distance, :drive_time, :school_id, :student_id, :tier, :eligibility, :transportation_eligibility,
									:walk_time, :walk_zone_eligibility, :sort_order_position, :bps_id, :ranked, :exam_school, :school_type, :starred,
									:ell_cluster, :ell_description, :sped_cluster, :sped_description, :call_id, :choice_rank,
                  :school_name, :program_code, :program_code_description


end
