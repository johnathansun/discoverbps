class StudentSchool < ActiveRecord::Base
	include RankedModel
	ranks :sort_order, :with_same => :student_id

	belongs_to :school
	belongs_to :student
  attr_accessible :distance, :drive_time, :school_id, :student_id, :tier, :eligibility, :transportation_eligibility,
									:walk_time, :walk_zone_eligibility, :sort_order_position, :bps_id, :ranked, :exam_school, :school_type, :starred,
									:ell_cluster, :ell_description, :sped_cluster, :sped_description, :call_id, :choice_rank,
                  :school_name, :program_code, :program_code_description, :special_admissions,:walk_distance,:dese_tier, :sort_order,
                  :tier_explanation, :school_dese_accountability

  def self.create_from_api_response(student, school, school_hash, school_list_type)

    Rails.logger.info "******************* #{school_hash}"

    self.create!(student_id: student.id,
                 school_id: school.id,
                 school_name: school_hash[:SchoolName],
                 school_type: school_list_type,
                 bps_id: (school_list_type == "ell" ? school_hash[:SchoolId] : school_list_type == "sped" ? school_hash[:SchoolID] : school_hash[:SchoolLocalId]),
                 tier: school_hash[:Tier],
                 eligibility: school_hash[:SchoolEligibility],
                 walk_zone_eligibility: school_hash[:AssignmentWalkEligibilityStatus],
                 transportation_eligibility: school_hash[:TransportationEligibility],
                 distance: school_hash[:StraightLineDistance],
                 exam_school: (school_hash[:IsExamSchool] == "0" ? false : true),
                 sped_cluster: school_hash[:SPEDCluster],
                 sped_description: school_hash[:Program],
                 ell_cluster: school_hash[:EllCluster],
                 ell_description: school_hash[:ProgramDescription],
                 program_code: ( school_list_type == "ell" ? school_hash[:ProgramCode] : school_list_type == "sped" ? school_hash[:MidCode] : school_hash[:ProgramId]),
                 program_code_description: ( school_list_type == "sped" ? school_hash[:ProgramDescription] : [:ProgramCodeDescription] ),
                 call_id: school_hash[:CallId],
                 special_admissions: school_hash[:IsSpecAdmissions],
                 walk_distance: school_hash[:WalkDistance],
                 dese_tier: school_hash[:DeseTier],
                 #TODO: was not included before. Verify once
                 # sort_order: school_hash[:SortOrder]
                 choice_rank: school_hash[:ChoiceRank],
                 tier_explanation: school_hash[:TierExplanation],
                 school_dese_accountability: school_hash[:SchoolDESEAccountability]
    )
  end
end
