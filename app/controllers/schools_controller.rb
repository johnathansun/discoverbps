class SchoolsController < ApplicationController
  # GET /schools
  # GET /schools.json
  def index
    # GET eligible schools
    response = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=03&StreetNumber=23&Street=Becket+st&ZipCode=02108")
    eligible_schools = response[:List]

    # GET school information
    @schools = []
    eligible_schools.each do |school|
      id = school[:School]
      school_hash = {}
      school_hash[:eligibility] = school
      school_hash[:basic_info] = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/schools.svc/GetSchool?schyear=2013&sch=#{id}")[0]
      school_hash[:description] = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/Schools.svc/GetSchoolDescriptions?schyear=2013&sch=#{id}")
      school_hash[:facilities] = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/Schools.svc/GetSchoolFacilities?schyear=2013&sch=#{id}")
      school_hash[:hours] = bps_api_connector("http://apps.mybps.org/WebServiceDiscoverBPSDEV/Schools.svc/GetSchoolHours?schyear=2013&sch=#{id}&TranslationLanguage=")
      school_hash[:grades] = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/Schools.svc/GetSchoolGrades?schyear=2013&sch=#{id}")
      school_hash[:partners] = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSDEV/Schools.svc/GetSchoolPartners?schyear=2013&sch=#{id}&TranslationLanguage=")
      school_hash[:photos] = bps_api_connector("http://apps.mybps.org/WebServiceDiscoverBPSDEV/Schools.svc/GetSchoolPhotos?schyear=2013&sch=#{id}")
      @schools << school_hash
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @schools }
    end
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @school }
    end
  end

  private

  def bps_api_connector(url)
    # if Rails.env == 'production'
    #   connection = Faraday.new(:url => url)
    #   @response = connection.get
    # else
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.ssl_version = :SSLv3
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @response = http.get(url)
    # end
    MultiJson.load(@response.body, :symbolize_keys => true)
  end

end
