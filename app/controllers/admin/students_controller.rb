class Admin::StudentsController < ApplicationController
	layout 'admin'

	def index
		if params[:letter].blank?
			@students = Student.order(:last_name)
		else
			@students = Student.where('lower(last_name) SIMILAR TO ?', "#{params[:letter]}%").order(:last_name)
		end
		
	end

	def show
		@student = Student.find(params[:id])
	end
end
