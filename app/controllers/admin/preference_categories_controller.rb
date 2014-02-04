class Admin::PreferenceCategoriesController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@preference_categories = PreferenceCategory.rank(:sort_order)
	end

	def new
		@preference_category = PreferenceCategory.new
	end

  def create
    @preference_category = PreferenceCategory.new(params[:preference_category])
    
    respond_to do |format|
      if @preference_category.save
        format.html { redirect_to admin_preferences_url, notice: 'Preference categorywas successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

	def edit
		@preference_category = PreferenceCategory.find(params[:id])
	end

	def update
		@preference_category = PreferenceCategory.find(params[:id])
    
    respond_to do |format|
      if @preference_category.update_attributes(params[:preference_category])
        format.html { redirect_to admin_preferences_url, notice: 'Preference category was successfully updated.' }          
      else
        format.html { render action: "edit" }
      end
    end
	end

	def destroy
    @preference_category = PreferenceCategory.find(params[:id])
    @preference_category.destroy
    
    respond_to do |format|
      format.html { redirect_to admin_preferences_url }
    end
  end
end
