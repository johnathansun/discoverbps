class PreferenceCategory < ActiveRecord::Base
	include RankedModel
	ranks :sort_order
	
	has_many :preferences

  attr_accessible :name, :description, :sort_order, :qualitative_criteria, :include_in_special_needs_dialog_box, :select_type, :glyph_id, :glyph_class

  scope :qualitative, where(qualitative_criteria: true)
  scope :special_needs, where(include_in_special_needs_dialog_box: true)
  scope :preference_panel, where(include_in_special_needs_dialog_box: false)
end
