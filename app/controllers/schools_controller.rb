class SchoolsController < ApplicationController
  layout :layout_selector

  def home
  end

  def index
    if session[:eligible_school_ids].present?
      @eligible_schools = School.where('id IN (?)', session[:eligible_school_ids])
    elsif current_student.present?
      street_number = current_student.street_number.present? ? URI.escape(current_student.street_number) : ''
      street_name   = current_student.street_name.present? ? URI.escape(current_student.street_name) : ''
      zipcode       = current_student.zipcode.present? ? URI.escape(current_student.zipcode) : ''
      eligible_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=03&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
      @eligible_schools = School.where('bps_id IN (?)', eligible_schools.collect {|x| x[:School]})
    end

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

  def layout_selector
    case action_name
    when "home"
      "home"
    else
      "application"
    end
  end

end
