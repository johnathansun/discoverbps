class Admin::SchoolsController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@schools = School.order(:name)
	end

	def show
		@school = School.find(params[:id])
	end

	def new
		@school = School.new
	end

  def create
    @school = School.new(params[:school])

    respond_to do |format|
      if @school.save
      	SchoolData.update_basic_info!(@school.id)
				SchoolData.delay.update_awards!(@school.id)
				SchoolData.delay.update_descriptions!(@school.id)
				SchoolData.delay.update_facilities!(@school.id)
				SchoolData.delay.update_grades!(@school.id)
				SchoolData.delay.update_hours!(@school.id)
				SchoolData.delay.update_languages!(@school.id)
				SchoolData.delay.update_partners!(@school.id)
				SchoolData.delay.update_photos!(@school.id)
				SchoolData.delay.update_sports!(@school.id)

        format.html { redirect_to admin_schools_url, notice: 'School was successfully created. The API data is being synced.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def destroy
    @school = School.find(params[:id])
    StudentSchool.where(school_id: @school.id).delete_all
    @school.destroy

    respond_to do |format|
      format.html { redirect_to admin_schools_url }
    end
  end
end
