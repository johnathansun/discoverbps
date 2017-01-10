class StudentSchool < ActiveRecord::Base
	include RankedModel
	ranks :sort_order, :with_same => :student_id

	belongs_to :school
	belongs_to :student
  attr_accessible :distance, :drive_time, :school_id, :student_id, :tier, :eligibility, :transportation_eligibility,
									:walk_time, :walk_zone_eligibility, :sort_order_position, :bps_id, :ranked, :exam_school, :school_type, :starred,
									:ell_cluster, :ell_description, :sped_cluster, :sped_description, :call_id, :choice_rank,
                  :school_name, :program_code, :program_code_description, :special_admissions,:walk_distance,:dese_tier

  def self.create_from_api_response(student, school, school_hash, school_list_type)
    Rails.logger.info "******************* #{school_hash}"

    self.create!(student_id: student.id,
      school_id: school.id,
      school_name: school_hash[:SchoolName],
      school_type: school_list_type,
      bps_id:(school_list_type == "choice") ? school_hash[:SchoolLocalId] : school_hash[:SchoolID],
      tier: school_hash[:Tier],
      eligibility: (school_list_type == "choice") ? school_hash[:SchoolEligibility] : school_hash[:Eligibility],
      walk_zone_eligibility: school_hash[:AssignmentWalkEligibilityStatus],
      transportation_eligibility: (school_list_type == "choice") ? school_hash[:TransportationEligibility] : school_hash[:TransEligible],
      distance: school_hash[:StraightLineDistance],
      exam_school: (school_hash[:IsExamSchool] == "0" ? false : true),
      sped_cluster: school_hash[:SPEDCluster],
      sped_description: school_hash[:Program],
      ell_cluster: school_hash[:ELLCluster],
      ell_description: school_hash[:ProgramDescription],
      program_code:  (school_list_type == "choice") ? school_hash[:ProgramId] :  school_hash[:ProgramCode],
      program_code_description: school_hash[:ProgramCodeDescription],
      call_id: (school_list_type == "choice") ? school_hash[:CallId] : school_hash[:CallID],
      special_admissions: school_hash[:IsSpecAdmissions],
      walk_distance: school_hash[:WalkLineDistance],
      dese_tier: school_hash[:DeseTier]
    )
  end
end
