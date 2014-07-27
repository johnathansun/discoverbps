class Admin::StudentsController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@students = Student.order(:last_name)

		respond_to do |format|
      format.html
      format.json do
      	Rails.cache.write("searches", Student.order(:last_name).to_json(only: [ :grade_level, :latitude, :longitude, :zipcode, :ell_needs, :iep_needs, :preferences_count  ], methods: :created_at_date))
      	logger.info Rails.cache.read("searches")
				render json: Rails.cache.read("searches")
      end
    end		
	end

	def show
		@student = Student.find(params[:id])
	end
end