class PreferenceCategory < ActiveRecord::Base
	include RankedModel
	ranks :sort_order
	
	has_many :preferences
  attr_accessible :name, :sort_order, :qualitative_criteria, :include_in_special_needs_dialog_box

  scope :qualitative, where(qualitative_criteria: true)
end
