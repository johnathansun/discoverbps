class SchoolsController < ApplicationController
  
  def home
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
