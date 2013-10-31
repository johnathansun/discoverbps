class StudentsController < ApplicationController
  layout 'home'

	def create
		first_name  = params.try(:[], :student).try(:[], :first_name)
    last_name   = params.try(:[], :student).try(:[], :last_name)
    zipcode     = params.try(:[], :student).try(:[], :zipcode)
    grade_level = params.try(:[], :student).try(:[], :grade_level)
      
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

    params[:student][:sibling_school_id] = School.where(name: params[:student][:sibling_school_name]).first.try(:bps_id)

    street_number = URI.escape(params[:student][:street_number].try(:strip))
    street_name   = URI.escape(params[:student][:street_name].try(:strip))
    zipcode       = URI.escape(params[:student][:zipcode].try(:strip))
        
    addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")

    @addresses = addresses.try(:[], :List)
    @errors = addresses.try(:[], :Error).try(:[], 0)

    respond_to do |format|
      if @addresses.present? && @student.update_attributes(params[:student])
        format.html { redirect_to address_verification_student_path(@student)}
        format.js { render template: "students/address_verification" }
      else
        if @addresses.blank?
          @student.errors[:base] << "We couldn't find any addresses in Boston that match your search. Please try again."
        end
        format.html { render action: errors }
        format.js { render template: "students/errors" }
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
        
        format.html { redirect_to address_verification_student_path(@student)}
        format.js { render template: "students/address_verification" }
      else
        if @addresses.blank?
          @student.errors[:base] << "We couldn't find any addresses in Boston that match your search. Please try again."
        end
        format.html { render action: errors }
        format.js { render template: "students/errors" }
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
        format.html { redirect_to special_needs_student_path(@student)}
        format.js { render template: "students/special_needs" }         
      else
        format.html
        format.js { render template: "students/errors" }
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
    students = Student.where('session_id = ? AND id IN (?)', session[:session_id], params[:student_ids])
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
