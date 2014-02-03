class Admin::PreferencesController < ApplicationController
	layout 'admin'

	def index
		@preference_categories = PreferenceCategory.rank(:sort_order)
	end

	def edit
		@preference = Preference.find(params[:id])
	end
end
