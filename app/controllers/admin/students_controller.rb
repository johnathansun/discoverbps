class Admin::StudentsController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@students = Student.order(:last_name)

		respond_to do |format|
      format.html
      format.json do
				render json: StoredSearch.first.try(:json)
      end
    end		
	end

	def show
		@student = Student.find(params[:id])
	end
end