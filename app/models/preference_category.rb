class PreferenceCategory < ActiveRecord::Base
	include RankedModel
	ranks :sort_order
	
	has_many :preferences
  attr_accessible :name
end
