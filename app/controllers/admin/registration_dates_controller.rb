class Admin::RegistrationDatesController < ApplicationController
  before_filter :authenticate_admin!
	layout 'admin'

	def index
		@registration_dates = RegistrationDate.order(:start_date)
	end

	def new
		@registration_date = RegistrationDate.new
	end

  def create
    @registration_date = RegistrationDate.new(params[:registration_date])

    respond_to do |format|
      if @registration_date.save
        format.html { redirect_to admin_registration_dates_url, notice: 'Registration date was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

	def edit
		@registration_date = RegistrationDate.find(params[:id])
	end

	def update
		@registration_date = RegistrationDate.find(params[:id])

    respond_to do |format|
      if @registration_date.update_attributes(params[:registration_date])
        format.html { redirect_to admin_registration_dates_url, notice: 'Registration date was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
	end

	def destroy
    # @registration_date = RegistrationDate.find(params[:id])
    # @registration_date.destroy

    respond_to do |format|
      format.html { redirect_to admin_registration_dates_url }
    end
  end
end
