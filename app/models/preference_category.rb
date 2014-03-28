class PreferenceCategory < ActiveRecord::Base
	include RankedModel
	ranks :sort_order
	
	has_many :preferences

  attr_accessible :name, :description, :sort_order, :qualitative_criteria, :include_in_special_needs_dialog_box, :include_in_preferences_panel, :select_type, :glyph_id, :glyph_class

   
  scope :special_needs, where(include_in_special_needs_dialog_box: true)
  scope :preference_panel, where(include_in_preferences_panel: true)

  def self.grade_level_categories(gl)
  	grade_level = gl.try(:downcase).try(:strip)
    PreferenceCategory.includes(:preferences).where("preferences.grade_#{grade_level} = ?", true).order("preference_categories.sort_order")
  end

  def grade_level_preferences(gl)
  	grade_level = gl.try(:downcase).try(:strip)
  	self.preferences.where("grade_#{grade_level} = ?", true).rank(:sort_order)
  end
end
