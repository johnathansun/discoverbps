class SchoolsController < ApplicationController
  include SchoolsHelper
  layout :layout_selector

  def home
    @students = Student.where(session_id: session[:session_id]).order(:first_name)
  end

  def index
    @students = Student.where(session_id: session[:session_id]).order(:first_name)

    if @students.blank?
      render 'home', layout: 'home'
    else
      if params[:student].present? && Student.where(first_name: params[:student], session_id: session[:session_id]).present?
        student = Student.where(first_name: params[:student], session_id: session[:session_id]).first
        session[:current_student_id] = student.id
      end

      street_number = current_student.street_number.present? ? URI.escape(current_student.street_number) : ''
      street_name   = current_student.street_name.present? ? URI.escape(current_student.street_name) : ''
      zipcode       = current_student.zipcode.present? ? URI.escape(current_student.zipcode) : ''
      grade_level   = current_student.grade_level.present? ? URI.escape(current_student.grade_level.try(:strip)) : ''
      
      eligible_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=#{grade_level}&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
      
      @eligible_schools = []
      @school_coordinates = ''
      
      # add virtual attributes to schools
      eligible_schools.each do |school|
        s = School.where(bps_id: school[:School]).first
        s.tier = school[:Tier]
        s.walk_zone_eligibility = school[:AssignmentWalkEligibilityStatus]
        s.transportation_eligibility = school[:TransEligible]
        @school_coordinates += "#{s.latitude},#{s.longitude}|"
        @eligible_schools << s
      end

      @school_coordinates.gsub!(/\|$/,'')
      @walk_info = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{@school_coordinates}&mode=walking&units=imperial&sensor=false")).get.body, :symbolize_keys => true)
      @drive_info = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{@school_coordinates}&mode=driving&units=imperial&sensor=false")).get.body, :symbolize_keys => true)

      # add virtual attributes to schools
      @eligible_schools.each_with_index do |school, i|
        school.walk_time = @walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
        school.drive_time = @drive_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
        school.distance = @walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :distance).try(:[], :text)
      end

      @eligible_schools.sort_by! {|x| x.distance}

      current_student.school_ids.clear
      current_student.school_ids = @eligible_schools.collect {|x| x.id}

      respond_to do |format|
        format.html # index.html.erb
        format.csv do
          require 'csv'
          csv_string = CSV.generate do |csv|
            csv << ['Name', 'Distance from Home', 'Walk Time', 'Drive Time', 'Hours', 'Grades Offered', 'Before School Programs', 'After School Programs', 'Facilities', 'MCAS Tier', 'School Type', 'School Focus', 'Special Application', 'Uniform Policy', 'Walk Zone Eligible', 'Transportation Eligible', 'School Email']
                      
            counter = 0
            @eligible_schools.each do |school|
              counter += 1
              csv << [ school.name, school.distance, school.walk_time, school.drive_time, school.api_hours.try(:[],0).try(:[], :schhours1), school.api_grades.try(:[], 0).try(:[], :grade), school.api_basic_info.try(:[], 0).try(:[], :BeforeSchPrograms), school.api_basic_info.try(:[], 0).try(:[], :AfterSchPrograms), facilities_list_helper(school.api_facilities[0]), "Tier #{school.tier}", school_type_helper(school.api_basic_info.try(:[], 0)), school.api_description.try(:[], 0).try(:[], :schfocus), school.api_description.try(:[], 0).try(:[], :specialapplicationnarrative), school.api_description.try(:[], 0).try(:[], :uniformpolicy), (school.walk_zone_eligibility == 'Y' ? 'Walk Zone Eligible' : ''), (school.transportation_eligibility == 'Y' ? 'Transportation' : ''), school.api_basic_info.try(:[], 0).try(:[], :schemail) ]
            end
          end

          send_data csv_string,
                    :type => 'text/csv; charset=iso-8859-1; header=present',
                    :disposition => "attachment; filename=#{current_student.first_name}_Schools.csv"
        end
      end
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

  def facilities_list_helper(hash)
    list = ''
    list << 'Art Room, '            if hash[:hasartroom] == 'True'
    list << 'Athletic Field, '      if hash[:hasathleticfield] == 'True'
    list << 'Auditorium, '          if hash[:hasauditorium] == 'True'
    list << 'Cafeteria, '           if hash[:hascafeteria] == 'True'
    list << 'Computer Lab, '        if hash[:hascomputerlab] == 'True'
    list << 'Gymnasium, '           if hash[:hasgymnasium] == 'True'
    list << 'Library, '             if hash[:haslibrary] == 'True'
    list << 'Music Room, '          if hash[:hasmusicroom] == 'True'
    list << 'Outdoor Classrooms, '  if hash[:hasoutdoorclassroom] == 'True'
    list << 'Playground, '          if hash[:hasplayground] == 'True'
    list << 'Pool, '                if hash[:haspool] == 'True'
    list << 'Science Lab, '         if hash[:hassciencelab] == 'True'
    return list.gsub(/,$/, '')
  end

end
