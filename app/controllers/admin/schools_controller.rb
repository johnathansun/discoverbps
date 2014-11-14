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

	def sync_all
		respond_to do |format|
			School.delay(priority: 2).sync_school_data!
			format.html { redirect_to admin_schools_url, notice: 'School data is being synced from the API' }
		end
	end

	def sync
		@school = School.find(params[:id])
		puts "************************ school = #{@school.bps_id}"
		respond_to do |format|
			if @school.present?
				School.delay(priority: 1).sync_school_data!(@school.id)
				format.html { redirect_to admin_school_url(@school), notice: 'School data is being synced from the API' }
			else
				format.html { render action: "list", alert: "We couldn't find that school" }
			end
		end
	end


end
