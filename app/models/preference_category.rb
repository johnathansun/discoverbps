class PreferenceCategory < ActiveRecord::Base
	include RankedModel
	ranks :sort_order
	
	has_many :preferences

  attr_accessible :name, :description, :sort_order, :qualitative_criteria, :include_in_special_needs_dialog_box, :select_type, :glyph_id, :glyph_class, :grade_K0, :grade_K1, :grade_K2, :grade_1, :grade_2, :grade_3, :grade_4, :grade_5, :grade_6, :grade_7, :grade_8, :grade_9, :grade_10, :grade_11, :grade_12

  scope :qualitative, where(qualitative_criteria: true)
  scope :special_needs, where(include_in_special_needs_dialog_box: true)
  scope :preference_panel, where(include_in_special_needs_dialog_box: false)

  def self.grade_level_categories(grade_level)
  	self.where("grade_#{grade_level}".downcase.to_sym => true)
  end
end
