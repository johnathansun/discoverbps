class Admin::StudentsController < ApplicationController
	layout 'admin'

	def index
		@students = Student.order('created_at DESC').paginate(:page => params[:submitted_page], :per_page => 100)
	end

	def show
		@student = Student.find(params[:id])
	end
end
