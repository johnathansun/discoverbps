class Preference < ActiveRecord::Base
	include RankedModel
	ranks :sort_order
	
	belongs_to :preference
  attr_accessible :name, :preference_category_id
end
