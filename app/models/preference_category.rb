class PreferenceCategory < ActiveRecord::Base
	include RankedModel
	ranks :sort_order

	has_many :preferences

  attr_accessible :name, :description, :sort_order, :qualitative_criteria, :include_in_special_needs_dialog_box, :include_in_preferences_panel, :select_type, :glyph_id, :glyph_class

  scope :special_needs, where(include_in_special_needs_dialog_box: true)
  scope :include_in_preferences_panel, where(include_in_preferences_panel: true)

	def self.active(grade)
		grade_level = grade.try(:downcase).try(:strip)
		PreferenceCategory.includes(:preferences).where("preference_categories.include_in_preferences_panel = ? AND preferences.grade_#{grade_level} = ?", true, true).order("preference_categories.sort_order")
	end

  def active_preferences(grade)
  	grade_level = grade.try(:downcase).try(:strip)
		Preference.where("preference_category_id = ? AND grade_#{grade_level} = ?", self.id, true).rank(:sort_order)
  end
end
