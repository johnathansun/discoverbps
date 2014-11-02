class Admin::NotificationsController < ApplicationController
	before_filter :authenticate_admin!
	layout 'admin'

	def index
		@notifications = Notification.order('start_time DESC')
	end

	def new
		@notification = Notification.new
	end

  def create
    @notification = Notification.new(params[:notification])

    respond_to do |format|
      if @notification.save
        format.html { redirect_to admin_notifications_url, notice: 'Notification was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

	def edit
		@notification = Notification.find(params[:id])
	end

	def update
		@notification = Notification.find(params[:id])

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to admin_notifications_url, notice: 'Notification was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
	end

	def destroy
    @notification = Notification.find(params[:id])
    @notification.destroy

    respond_to do |format|
      format.html { redirect_to admin_notifications_url }
    end
  end
end
