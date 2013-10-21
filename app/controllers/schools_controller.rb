class SchoolsController < ApplicationController
  include SchoolsHelper
  layout :layout_selector

  def home
    # session.clear
    if current_user
      @students = current_user.students
    else
      @students = Student.where(session_id: session[:session_id]).order(:first_name)
    end
  end

  def index
    if current_user
      @students = current_user.students
    else
      @students = Student.where(session_id: session[:session_id]).order(:first_name)
    end

    if @students.blank?
      render 'home', layout: 'home'
    else
      # Set current_student if it's specified in the params
      if params[:student].present? 
        if current_user.present? && current_user.students.where(first_name: params[:student]).first.present?
          session[:current_student_id] = current_user.students.where(first_name: params[:student]).first.id
        elsif Student.where(first_name: params[:student], session_id: session[:session_id]).present?
          session[:current_student_id] = Student.where(first_name: params[:student], session_id: session[:session_id]).first.id
        end
      end

      # Hit the API if the student has no saved schools, or if the cache is stale (> 24 hours)
      if current_student.schools.blank? || current_student.schools_last_updated_at.blank? || current_student.schools_last_updated_at < Time.now.yesterday
        @student_schools = get_school_choices
      elsif current_student.schools.present?
        @student_schools = current_student.student_schools.rank(:sort_order)
      else
        @student_schools = []
      end

      respond_to do |format|
        format.html # index.html.erb
        format.csv do
          require 'csv'
          csv_string = CSV.generate do |csv|
            csv << ['Name', 'Distance from Home', 'Walk Time', 'Drive Time', 'Transportation Eligibility', 'Hours', 'Grades Offered', 'Before School Programs', 'After School Programs', 'Facilities', 'Partners', 'MCAS Tier', 'School Type', 'School Focus', 'Special Application', 'Uniform Policy', 'School Email']
                      
            counter = 0
            @eligible_schools.each do |school|
              counter += 1
              csv << [ school.name, school.distance, school.walk_time, school.drive_time, school.transportation_eligibility, school.api_hours.try(:[],0).try(:[], :schhours1), school.api_grades.try(:[], 0).try(:[], :grade), school.api_basic_info.try(:[], 0).try(:[], :BeforeSchPrograms), school.api_basic_info.try(:[], 0).try(:[], :AfterSchPrograms), facilities_list_helper(school.api_facilities.try(:[], 0)), partners_list_helper(school.api_partners), "Tier #{school.tier}", school_type_helper(school.api_basic_info.try(:[], 0)), school.api_description.try(:[], 0).try(:[], :schfocus), school.api_description.try(:[], 0).try(:[], :specialapplicationnarrative), school.api_description.try(:[], 0).try(:[], :uniformpolicy), school.api_basic_info.try(:[], 0).try(:[], :schemail) ]
            end
          end

          send_data csv_string,
                    :type => 'text/csv; charset=iso-8859-1; header=present',
                    :disposition => "attachment; filename=#{current_student.first_name}s_eligible_schools.csv"
        end
      end
    end
  end

  def compare
    if current_user
      @students = current_user.students
    else
      @students = Student.where(session_id: session[:session_id]).order(:first_name)
    end
  end

  def print
    index
  end

  def show
    @school = School.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @school }
    end
  end

  # POST
  def sort
    if params[:school].present?
      params[:school].flatten.each_with_index do |bps_id, i|
        student_school = current_student.student_schools.where(bps_id: bps_id).first
        if student_school.present?
          student_school.update_attributes(sort_order_position: i, ranked: true)
        end
      end
    end
    render nothing: true
  end

  private

    # this method pulls a list of eligible schools from the GetSchoolChoices API, 
    # saves the schools to student_schools, and fetches distance and walk/drive times from the Google Matrix API
    def get_school_choices
      if current_student.street_number.present? && current_student.street_name.present? && current_student.zipcode.present?
        logger.info "************ refreshing student_schools"
  
        street_number = URI.escape(current_student.street_number)
        street_name   = URI.escape(current_student.street_name)
        zipcode       = current_student.zipcode.strip
        grade_level   = current_student.grade_level.to_s.length < 2 ? ('0' + current_student.grade_level.try(:strip)) : current_student.grade_level.try(:strip)

        # hit the BPS API
        api_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=#{grade_level}&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]
        
        school_coordinates = ''

        # loop through the schools returned from the API, find the matching schools in the db,
        # and save the eligibility variables on student_schools
        api_schools.each do |school|
          school = School.where(bps_id: school[:School]).first
          if school.present?
            school_coordinates += "#{school.latitude},#{school.longitude}|"
            student_school = current_student.student_schools.where(school_id: school.id).first_or_initialize
            student_school.bps_id                     = school[:School]
            student_school.tier                       = school[:Tier]
            student_school.walk_zone_eligibility      = school[:AssignmentWalkEligibilityStatus]
            student_school.transportation_eligibility = school[:TransEligible]
            student_school.save
          end
        end
        
        # hit the Google Distance Matrix API to gather distances, drive times and walk times 
        # between the student's home address to all of his/her eligible schools
        school_coordinates.gsub!(/\|$/,'')
        walk_info   = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=walking&units=imperial&sensor=false")).get.body, :symbolize_keys => true)
        drive_info  = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=driving&units=imperial&sensor=false")).get.body, :symbolize_keys => true)

        # save distance, walk time and drive time on the student_schools join table
        api_schools.each_with_index do |school, i|
          school = School.where(bps_id: school[:School]).first
          if school.present?
            student_school             = current_student.student_schools.where(school_id: school.id).first_or_initialize
            student_school.distance    = walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :distance).try(:[], :text)
            student_school.walk_time   = walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
            student_school.drive_time  = drive_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
            student_school.save
          end
        end

        current_student.update_attributes(schools_last_updated_at: Time.now)
        return current_student.student_schools.rank(:sort_order)
      else
        return []
      end
    end

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
      when "print"
        "print"
      else
        "application"
      end
    end

end
