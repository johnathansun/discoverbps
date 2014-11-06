class StudentsController < ApplicationController

	def index
	end

	def create

    if params[:student].present? && params[:student][:grade_level].present? && params[:student][:street_number].present? && params[:student][:street_name].present? && params[:student][:zipcode].present?

  		first_name    = params[:student][:first_name]
      last_name     = params[:student][:last_name]
      grade_level   = params[:student][:grade_level]
      street_number = params[:student][:street_number]
      street_name   = params[:student][:street_name]
      zipcode       = params[:student][:zipcode]

			@student = get_or_set_student(current_user, first_name, last_name, grade_level)

      params[:student][:sibling_school_ids] = School.where("name IN (?)", params[:student][:sibling_school_names].try(:compact).try(:reject, &:empty?)).collect {|x| x.bps_id}.uniq

			api_response = Webservice.address_matches(street_number, street_name, zipcode)
      @addresses = api_response.try(:[], :List)
			@errors = api_response.try(:[], :Error).try(:[], 0)

    end

    respond_to do |format|
      if @addresses.present? && @student.present? && @student.update_attributes(params[:student])
				session[:current_student_id] = @student.id
        format.js { render template: "students/address/addresses" }
        format.html { redirect_to addresses_student_path(@student)}
      else
        if api_response.present?
          if @addresses.blank?
            if @errors.present?
              @error_message = @errors
              flash[:alert] = "There were problems with your search. Please enter the required fields and try again."
            else
              @error_message = "We couldn't find any addresses in Boston that match your search. Please try again."
              flash[:alert] = "We couldn't find any addresses in Boston that match your search. Please try again."
            end
          end

        else
          @error_message = "Please enter the required search fields and try again."
          flash[:alert] = "Please enter the required search fields and try again."
        end

        format.js { render template: "students/errors/errors" }
        format.html { redirect_to root_url }
      end
    end
  end

  def update
  	@student = Student.find(params[:id])

    street_number = params[:student].try(:[], :street_number)
    street_name   = params[:student].try(:[], :street_name)
    zipcode       = params[:student].try(:[], :zipcode)

    api_response = Webservice.address_matches(street_number, street_name, zipcode)
    @addresses = api_response.try(:[], :List)
    @errors = api_response.try(:[], :Error).try(:[], 0)

    respond_to do |format|
      if @addresses.present? && @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id

        format.js { render template: "students/address/addresses" }
        format.html { redirect_to addresses_student_path(@student)}
      else
        if @addresses.blank?
          if @errors.present?
            @error_message = @errors
          else
            @error_message = "We couldn't find any addresses in Boston that match your search. Please try again."
          end
        end
        format.js { render template: "students/errors/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

	# ADDRESS DIALOG BOX

  def addresses
    @student = Student.find(params[:id])

    street_number = @student.street_number
    street_name   = @student.street_name
    zipcode       = @student.zipcode

		api_response = Webservice.address_matches(street_number, street_name, zipcode)
		@addresses = api_response.try(:[], :List)
    @errors = api_response.try(:[], :Error).try(:[], 0)
  end

  def verify_address
    @student = Student.find(params[:id])
    params[:student][:address_verified] = true

    respond_to do |format|
      if @student.update_attributes(params[:student])

				# set the basic school lists here, since this step will save the student
				# home schools will be overwritten in set_awc if awc_invitation = true
				@student.set_home_schools!
				if zone_school_grades.include?(@student.grade_level)
					@student.set_zone_schools!
				end

				# format.html { redirect_to schools_path}
				# format.js { render :js => "window.location = '/schools'" }

        format.js { render template: "students/ell/ell" }
        format.html { redirect_to ell_student_path(@student)}

      else
        format.js { render template: "students/errors/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

	# ELL DIALOG BOX

	def ell
		@student = Student.find(params[:id])
	end

	def set_ell
		@student = Student.find(params[:id])

		respond_to do |format|
			if @student.update_attributes(params[:student])

				if @student.ell_language != false
					@student.set_ell_schools!
				end

				format.html { redirect_to schools_path}
				format.js { render :js => "window.location = '/schools'" }

				# format.html { redirect_to sped_student_path(@student)}
				# format.js { render template: "students/sped/sped" }
			else
				format.js { render template: "students/ell/ell" }
				flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
				format.html { redirect_to root_url }
			end
		end
	end


	# SPED DIALOG BOX

	def sped
		@student = Student.find(params[:id])
	end

	def set_sped
		@student = Student.find(params[:id])

		respond_to do |format|
			if @student.update_attributes(params[:student])

				if @student.sped_needs == true
					@student.set_sped_schools!
				end

				if AWC_GRADES.include?(@student.grade_level)
					format.html { redirect_to awc_student_path(@student)}
					format.js { render template: "students/awc/awc" }
				else
					@student.set_home_schools!
					format.html { redirect_to schools_path}
					format.js { render :js => "window.location = '/schools'" }
				end
			else
				format.js { render template: "students/sped/sped" }
				flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
				format.html { redirect_to root_url }
			end
		end
	end

	# AWC DIALOG BOX

	def awc
		@student = Student.find(params[:id])
	end

	def set_awc
		@student = Student.find(params[:id])

		respond_to do |format|
			if @student.update_attributes(params[:student])

				# overwrite home_schools if awc = true
				if params[:student][:awc_invitation] == true
					@student.set_home_schools!
				end

				format.html { redirect_to schools_path}
				format.js { render :js => "window.location = '/schools'" }
			else
				format.js { render template: "students/awc/awc" }
				flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
				format.html { redirect_to root_url }
			end
		end
	end



  def destroy
    @student = Student.find(params[:id])
    @student.destroy
    session[:current_student_id] = nil

    respond_to do |format|
      format.html { redirect_to root_url }
    end
  end

  def save_preference
    current_student.preferences.clear
    if params.try(:[], :student).try(:[], :preference_ids).present?
      params[:student][:preference_ids].each do |name|
        current_student.preferences << Preference.where(name: name)
      end
    end
    render nothing: true
  end

  def remove_notification
    logger.info params
    if session[:removed_notifications].present?
      session[:removed_notifications] << params[:notification_id]
      session[:removed_notifications].uniq!
    else
      session[:removed_notifications] = []
      session[:removed_notifications] << params[:notification_id]
      session[:removed_notifications].uniq!
    end
    render nothing: true
  end

	private

	def get_or_set_student(current_user, first_name, last_name, grade_level)
		if current_user.present?
			if first_name.present? && last_name.present?
				Student.where(user_id: current_user.id, first_name: first_name, last_name: last_name).first_or_initialize
			elsif first_name.present?
				Student.where(user_id: current_user.id, first_name: first_name).first_or_initialize
			else
				Student.where(user_id: current_user.id, grade_level: grade_level).first_or_initialize
			end
		elsif session[:session_id].present?
			if first_name.present? && last_name.present?
				Student.where(session_id: session[:session_id], first_name: first_name, last_name: last_name).first_or_initialize
			elsif first_name.present?
				Student.where(session_id: session[:session_id], first_name: first_name).first_or_initialize
			else
				Student.where(session_id: session[:session_id], grade_level: grade_level).first_or_initialize
			end
		else
			nil
		end
	end

end
