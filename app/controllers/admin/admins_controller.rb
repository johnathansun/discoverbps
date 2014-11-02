class Admin::AdminsController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@admins = Admin.all
	end

	def new
		@admin = Admin.new
	end

  def create
    @admin = Admin.new(params[:admin])

    respond_to do |format|
      if @admin.save
        format.html { redirect_to admin_admins_url, notice: 'Admin was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

	def edit
		@admin = Admin.find(params[:id])
	end

	def update
		@admin = Admin.find(params[:id])

    respond_to do |format|
      if @admin.update_attributes(params[:admin])
        format.html { redirect_to admin_admins_url, notice: 'Admin was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
	end

	def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy

    respond_to do |format|
      format.html { redirect_to admin_admins_url }
    end
  end
end
