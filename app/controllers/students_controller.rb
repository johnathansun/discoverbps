class StudentsController < ApplicationController
	def create
    @student = Student.where(session_id: session[:session_id], first_name: params[:student][:first_name], last_name: params[:student][:last_name]).first_or_create
    
    respond_to do |format|
      if @student.update_attributes(params[:student])
      	logger.info "*********** setting current_student_id to #{@student.id}"
        session[:current_student_id] = @student.id  	
      	street_number = URI.escape(params[:student][:street_number].try(:strip))
        street_name   = URI.escape(params[:student][:street_name].try(:strip))
        zipcode       = URI.escape(params[:student][:zipcode].try(:strip))
        
        @addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
        
        format.js { render template: "students/address_verification" }
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  def address_verification
    @student = Student.find(params[:id])
    
    respond_to do |format|
      if @student.update_attributes(params[:student])
        format.js { render template: "students/iep" }         
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  def iep
    @student = Student.find(params[:id])
    
    respond_to do |format|
      if @student.update_attributes(params[:student])
      	if params[:student][:primary_language].present? && params[:student][:primary_language] != 'English'
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

      	street_number = @student.street_number.present? ? URI.escape(@student.street_number) : ''
    		street_name   = @student.street_name.present? ? URI.escape(@student.street_name) : ''
    		zipcode       = @student.zipcode.present? ? URI.escape(@student.zipcode) : ''

		    eligible_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=03&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
		    eligible_school_ids = eligible_schools.collect {|x| x[:School]}
		    
		    session[:school_ids] = eligible_school_ids
		    
		    @schools = School.where('bps_id IN (?)', eligible_school_ids)
    
	      format.js { render :js => "window.location = '/schools/'" }        
      else
        format.js { render template: "students/errors" }
      end
    end
  end

  private

  def bps_api_connector(url)
    response = Faraday.new(:url => url, :ssl => {:version => :SSLv3}).get
    if response.body.present?
      MultiJson.load(response.body, :symbolize_keys => true)
    end
  end
end
