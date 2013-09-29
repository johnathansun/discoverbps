class SchoolsController < ApplicationController
  
  def home
  end

  def address_search
    respond_to do |format|
      if params[:street_number].blank? || params[:street_name].blank? || params[:zipcode].blank? || params[:first_name].blank?
        logger.info "************** This is an error"
        @errors = 'Please complete all of the form fields before submitting.'
        format.js { render action: "errors" }
      else
        session[:first_name]    = params[:first_name].try(:strip)
        session[:last_name]     = params[:last_name].try(:strip)
        session[:grade_level]   = params[:grade_level].try(:strip)

        street_number = URI.escape(params[:street_number].try(:strip))
        street_name   = URI.escape(params[:street_name].try(:strip))
        zipcode       = URI.escape(params[:zipcode].try(:strip))
        
        @addresses = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/schools.svc/GetAddressMatches?StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
        format.js { render action: "address_verification" }
      end
    end
  end

  def address_verification
    respond_to do |format|
      session[:street_number] = params[:hidden_street_number].try(:strip)
      session[:street_name]   = params[:hidden_street_name].try(:strip)
      session[:zipcode]       = params[:hidden_zipcode].try(:strip)
      format.js { render action: "iep_needs" }
    end
  end

  def iep_needs
    respond_to do |format|
      session[:iep_needs]         = params[:iep_needs]
      session[:primary_language]  = params[:primary_language]
      format.js { render action: "ell_needs" }
    end
  end

  def ell_needs
    respond_to do |format|
      # session[:iep_needs]         = params[:iep_needs]
      # session[:primary_language]  = params[:primary_language]
      format.js { render action: "preferences" }
    end
  end

  def index
    street_number = session[:street_number].present? ? URI.escape(session[:street_number]) : ''
    street_name   = session[:street_name].present? ? URI.escape(session[:street_name]) : ''
    zipcode       = session[:zipcode].present? ? URI.escape(session[:zipcode]) : ''

    eligible_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=03&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]

    # GET school information
    @schools = School.where('bps_id IN (?)', eligible_schools.collect {|x| x[:School]})
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schools }
    end
  end

  def show
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @school }
    end
  end

  def print
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @school }
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
