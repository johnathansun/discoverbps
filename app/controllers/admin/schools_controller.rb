class Admin::SchoolsController < ApplicationController
	layout 'admin'

	def index	
		@schools = School.order(:name)
	end

	def show
		@school = School.find(params[:id])
	end
end
