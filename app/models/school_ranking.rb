class SchoolRanking < ActiveRecord::Base
  attr_accessible :sorted_school_ids, :student_id, :user_id
  serialize :sorted_school_ids
end
