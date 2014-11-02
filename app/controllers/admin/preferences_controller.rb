class Admin::PreferencesController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@preference_categories = PreferenceCategory.rank(:sort_order)
	end

	def new
		@preference = Preference.new
	end

  def create
    @preference = Preference.new(params[:preference])

    respond_to do |format|
      if @preference.save
        format.html { redirect_to admin_preferences_url, notice: 'Preference was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

	def edit
		@preference = Preference.find(params[:id])
	end

	def update
		@preference = Preference.find(params[:id])

    respond_to do |format|
      if @preference.update_attributes(params[:preference])
        format.html { redirect_to admin_preferences_url, notice: 'Preference was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
	end

	def destroy
    @preference = Preference.find(params[:id])
    @preference.destroy

    respond_to do |format|
      format.html { redirect_to admin_preferences_url }
    end
  end

  def sort
    id = params['preference']['id'].gsub(/preference_/, '')
    Preference.find(id).update_attribute(:sort_order_position, params['preference']['sort_order'])
    render :nothing => true
  end
end
