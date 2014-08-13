class StudentsController < ApplicationController

	def create

    if params[:student].present? && 
      params[:student][:grade_level].present? && 
      params[:student][:street_number].present? && 
      params[:student][:street_name].present? && 
      params[:student][:zipcode].present?

  		first_name    = params[:student][:first_name].try(:strip)
      last_name     = params[:student][:last_name].try(:strip)
      grade_level   = params[:student][:grade_level].try(:strip)
      street_number = URI.escape(params[:student][:street_number].try(:gsub, /\D/, ''))
      street_name   = URI.escape(params[:student][:street_name].try(:strip))
      zipcode       = URI.escape(params[:student][:zipcode].try(:strip))

      if current_user.present?
        if first_name.present? && last_name.present?
  				@student = Student.where(user_id: current_user.id, first_name: first_name, last_name: last_name).first_or_initialize
  			elsif first_name.present?
  				@student = Student.where(user_id: current_user.id, first_name: first_name).first_or_initialize
  			else
  				@student = Student.where(user_id: current_user.id, grade_level: grade_level).first_or_initialize
  			end
  		else
  			if first_name.present? && last_name.present?
  				@student = Student.where(session_id: session[:session_id], first_name: first_name, last_name: last_name).first_or_initialize
  			elsif first_name.present?
  				@student = Student.where(session_id: session[:session_id], first_name: first_name).first_or_initialize
  			else
  				@student = Student.where(session_id: session[:session_id], grade_level: grade_level).first_or_initialize
  			end
  		end

      params[:student][:sibling_school_ids] = School.where("name IN (?)", params[:student][:sibling_school_names].try(:compact).try(:reject, &:empty?)).collect {|x| x.bps_id}.uniq
          
      api_response = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")

      @addresses = api_response.try(:[], :List)
      @api_errors = api_response.try(:[], :Error).try(:[], 0)
    
    end

    respond_to do |format|
      if @addresses.present? && @student.update_attributes(params[:student])
        format.js { render template: "students/address_verification" }
        format.html { redirect_to address_verification_student_path(@student)}
      else
        if api_response.present?
          if @addresses.blank?
            if @api_errors.present?
              @error_message = @api_errors
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
        
        format.js { render template: "students/errors" }
        format.html { redirect_to root_url }
      end
    end
  end

  def update
  	@student = Student.find(params[:id])

    street_number = URI.escape(params[:student].try(:[], :street_number).try(:strip))
    street_name   = URI.escape(params[:student].try(:[], :street_name).try(:strip))
    zipcode       = URI.escape(params[:student].try(:[], :zipcode).try(:strip))
        
    addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")
    @addresses = addresses.try(:[], :List)
    @errors = addresses.try(:[], :Error).try(:[], 0)

    respond_to do |format|
      if @addresses.present? && @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id
        
        format.js { render template: "students/address_verification" }
        format.html { redirect_to address_verification_student_path(@student)}
      else
        if @addresses.blank?
          if @errors.present?
            @error_message = @errors
          else
            @error_message = "We couldn't find any addresses in Boston that match your search. Please try again."
          end
        end
        format.js { render template: "students/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

  def address_verification
    @student = Student.find(params[:id])

    street_number = URI.escape(@student.street_number.try(:strip))
    street_name   = URI.escape(@student.street_name.try(:strip))
    zipcode       = URI.escape(@student.zipcode.try(:strip))
        
    addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")
    @addresses = addresses.try(:[], :List)
    @errors = addresses.try(:[], :Error).try(:[], 0)
  end

  def verify_address
    @student = Student.find(params[:id])
    params[:student][:address_verified] = true

    respond_to do |format|
      if @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id 
        format.js { render template: "students/special_needs" }         
        format.html { redirect_to special_needs_student_path(@student)}
      else
        format.js { render template: "students/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

  def special_needs
    @student = Student.find(params[:id])
    
  end

  def set_special_needs
    @student = Student.find(params[:id])
    if params[:student].blank?
    	params[:student] = {}
	    params[:student][:iep_needs] = '0'
	    params[:student][:ell_needs] = '0'
		else
	    if params[:student][:iep_needs].blank?
		    params[:student][:iep_needs] = '0'
	  	end
	  	if params[:student][:ell_needs].blank?
		    params[:student][:ell_needs] = '0'
	  	end
	  end

    respond_to do |format|
      if @student.update_attributes(params[:student])
      	session[:current_student_id] = @student.id  
      	if @student.ell_needs?
          format.html { redirect_to ell_needs_student_path(@student)}
	        format.js { render template: "students/ell_needs" }
	      elsif @student.iep_needs?
          format.html { redirect_to iep_needs_student_path(@student)}
          format.js { render template: "students/iep_needs" }
        else
          format.html { redirect_to schools_path}
	        format.js { render :js => "window.location = '/schools'" }
	      end
      else
        format.js { render template: "students/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

  def ell_needs
    @student = Student.find(params[:id])
    
  end

  def iep_needs
    @student = Student.find(params[:id])
    
  end

  def destroy
    @student = Student.find(params[:id])
    @student.destroy
    session[:current_student_id] = nil

    respond_to do |format|
      format.html { redirect_to schools_url }
    end
  end

  def delete_all
    students = Student.where('id IN (?)', params[:student_ids])
    if students.present?
      students.each do |student|
        student.destroy
      end
    end
    session[:current_student_id] = nil
    respond_to do |format|
      format.html { redirect_to home_schools_url }
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

  def bps_api_connector(url)
    response = Faraday.new(:url => url, :ssl => {:version => :SSLv3}).get
    if response.body.present?
      MultiJson.load(response.body, :symbolize_keys => true) rescue {Error: ['The server responded with an error. Please try your search again later.']}
    else
      {Error: ['The server responded with an error. Please try your search again later.']}
    end
  end
end
