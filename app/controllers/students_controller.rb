class StudentsController < ApplicationController

	def create
		if current_user.present?
			if params[:student][:first_name].present? && params[:student][:last_name].present?
				@student = Student.where(user_id: current_user.id, first_name: params[:student][:first_name], last_name: params[:student][:last_name]).first_or_create
			elsif params[:student][:first_name].present?
				@student = Student.where(user_id: current_user.id, first_name: params[:student][:first_name]).first_or_create
			else
				@student = Student.where(user_id: current_user.id, grade_level: params[:student][:grade_level]).first_or_create
			end
		else
			if params[:student][:first_name].present? && params[:student][:last_name].present?
				@student = Student.where(session_id: session[:session_id], first_name: params[:student][:first_name], last_name: params[:student][:last_name]).first_or_create
			elsif params[:student][:first_name].present?
				@student = Student.where(session_id: session[:session_id], first_name: params[:student][:first_name]).first_or_create
			else
				@student = Student.where(session_id: session[:session_id], grade_level: params[:student][:grade_level]).first_or_create
			end
		end

    params[:student][:sibling_school_id] = School.where(name: params[:student][:sibling_school_name]).first.try(:bps_id)

    respond_to do |format|
      if @student.update_attributes(params[:student])
      	street_number = URI.escape(params[:student][:street_number].try(:strip))
        street_name   = URI.escape(params[:student][:street_name].try(:strip))
        zipcode       = URI.escape(params[:student][:zipcode].try(:strip))
        
        @addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}").try(:[], :List)

        if @addresses.present?
          format.html { redirect_to verify_address_students_url}
          format.js { render template: "students/address_verification" }
        else
          format.js { render template: "students/errors" }
        end
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  def update
  	@student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id
      	street_number = URI.escape(params[:student][:street_number].try(:strip))
        street_name   = URI.escape(params[:student][:street_name].try(:strip))
        zipcode       = URI.escape(params[:student][:zipcode].try(:strip))
        
        @addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}").try(:[], :List)
        
        if @addresses.present?
          format.js { render template: "students/address_verification" }
        else
          format.js { render template: "students/errors" }
        end
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  def verify_address
    
  end

  def address_verification
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id  
        format.js { render template: "students/iep" }         
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  def iep
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
	        format.js { render template: "students/ell" }
	      else
	        format.js { render template: "students/preferences" }
	      end
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  def ell
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id  
        format.js { render template: "students/preferences" }         
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  def preferences
    @student = Student.find(params[:id])
    
    respond_to do |format|
      if @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id    
	      format.html { redirect_to schools_url }
      end
    end
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
    students = Student.where('session_id = ? AND id IN (?)', session[:session_id], params[:student_ids])
    logger.info "************************* #{students}"
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

  private

  def bps_api_connector(url)
    response = Faraday.new(:url => url, :ssl => {:version => :SSLv3}).get
    if response.body.present?
      MultiJson.load(response.body, :symbolize_keys => true)
    end
  end
end
