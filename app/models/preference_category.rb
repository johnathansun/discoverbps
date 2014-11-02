class PreferenceCategory < ActiveRecord::Base
	include RankedModel
	ranks :sort_order

	has_many :preferences

  attr_accessible :name, :description, :sort_order, :qualitative_criteria, :include_in_special_needs_dialog_box, :include_in_preferences_panel, :select_type, :glyph_id, :glyph_class


  scope :special_needs, where(include_in_special_needs_dialog_box: true)
  scope :preference_panel, where(include_in_preferences_panel: true)

  def self.grade_level_categories(grade)
  	grade_level = grade.try(:downcase).try(:strip)
    PreferenceCategory.includes(:preferences).where("preferences.grade_#{grade_level} = ?", true).order("preference_categories.sort_order")
  end

  def grade_level_preferences(grade)
  	grade_level = grade.try(:downcase).try(:strip)
  	Preference.includes(:preference_category).where("preference_category_id = ? AND preferences.grade_#{grade_level} = ?", self.id, true).rank(:sort_order)
  end
end
