class SchoolsController < ApplicationController
  include SchoolsHelper
  layout :layout_selector

  def coming_soon
  end

  def home
  end


  def index
    if current_user_students.blank?
      render 'home', layout: 'home'
    else
      # Set current_student if it's specified in the params
      if params[:student].present?
        if current_user.present? && current_user.students.find(params[:student]).present?
          session[:current_student_id] = current_user.students.find(params[:student]).id
        elsif Student.where(id: params[:student], session_id: session[:session_id]).present?
          session[:current_student_id] = Student.where(id: params[:student], session_id: session[:session_id]).first.id
        end
      end

      if current_student.blank?
        session[:current_student_id] = current_user_students.first.id
      end

      @home_schools = get_home_schools


      respond_to do |format|
        format.html # index.html.erb
        format.csv do
          require 'csv'
          csv_string = CSV.generate do |csv|
            csv << ['Name', 'Distance from Home', 'Walk Time', 'Drive Time', 'Transportation Eligibility', 'Hours', 'Grades Offered', 'Before School Programs', 'After School Programs', 'Facilities', 'Partners', 'MCAS Tier', 'School Type', 'School Focus', 'Special Application', 'Uniform Policy', 'School Email']
                      
            counter = 0
            @home_schools.each do |student_school|
              school = student_school.school
              counter += 1
              csv << [ school.name, student_school.distance, student_school.walk_time, student_school.drive_time, school.transportation_eligibility, school.api_hours.try(:[], :schhours1), grade_levels_helper(school.grade_levels), school.api_basic_info.try(:[], :BeforeSchPrograms), school.api_basic_info.try(:[], :AfterSchPrograms), facilities_list_helper(school.api_facilities), partners_list_helper(school.api_partners), "Tier #{school.tier}", school_type_helper(school.api_basic_info), school.api_description.try(:[], :schfocus), school.api_description.try(:[], :specialapplicationnarrative), school.api_description.try(:[], :uniformpolicy), school.api_basic_info.try(:[], :schemail) ]
            end
          end

          send_data csv_string,
                    :type => 'text/csv; charset=iso-8859-1; header=present',
                    :disposition => "attachment; filename=#{current_student.first_name}s_eligible_schools.csv"
        end
      end
    end
  end

  def zone_schools
    if current_user_students.blank?
      render 'home', layout: 'home'
    else
      # Set current_student if it's specified in the params
      if params[:student].present?
        if current_user.present? && current_user.students.find(params[:student]).present?
          session[:current_student_id] = current_user.students.find(params[:student]).id
        elsif Student.where(id: params[:student], session_id: session[:session_id]).present?
          session[:current_student_id] = Student.where(id: params[:student], session_id: session[:session_id]).first.id
        end
      end

      if current_student.blank?
        session[:current_student_id] = current_user_students.first.id
      end

      if NON_TRANSITION_GRADES.include?(current_student.grade_level)
        @zone_schools = get_zone_schools
      else
        @zone_schools = []
      end

      respond_to do |format|
        format.html # index.html.erb
        format.csv do
          require 'csv'
          csv_string = CSV.generate do |csv|
            csv << ['Name', 'Distance from Home', 'Walk Time', 'Drive Time', 'Transportation Eligibility', 'Hours', 'Grades Offered', 'Before School Programs', 'After School Programs', 'Facilities', 'Partners', 'MCAS Tier', 'School Type', 'School Focus', 'Special Application', 'Uniform Policy', 'School Email']
                      
            counter = 0
            @zone_schools.each do |student_school|
              school = student_school.school
              counter += 1
              csv << [ school.name, student_school.distance, student_school.walk_time, student_school.drive_time, school.transportation_eligibility, school.api_hours.try(:[],0).try(:[], :schhours1), school.api_grades.try(:[], :grade), school.api_basic_info.try(:[], :BeforeSchPrograms), school.api_basic_info.try(:[], :AfterSchPrograms), facilities_list_helper(school.api_facilities), partners_list_helper(school.api_partners), "Tier #{school.tier}", school_type_helper(school.api_basic_info), school.api_description.try(:[], :schfocus), school.api_description.try(:[], :specialapplicationnarrative), school.api_description.try(:[], :uniformpolicy), school.api_basic_info.try(:[], :schemail) ]
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
    if current_user_students.blank?
      render 'home', layout: 'home'
    else
      respond_to do |format|
        format.html
      end
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
    key = params.keys.first
    student = Student.find(key)
    if student.present?
      params[key].flatten.each_with_index do |bps_id, i|
        student_school = student.student_schools.where(bps_id: bps_id).first
        if student_school.present?
          student_school.update_attributes(sort_order_position: i, ranked: true)
        end
      end
    end
  end

  private

    # this method pulls a list of eligible schools from the GetSchoolChoices API, 
    # saves the schools to student_schools, and fetches distance and walk/drive times from the Google Matrix API
    def get_home_schools
      if current_student.present? && current_student.street_number.present? && current_student.street_name.present? && current_student.zipcode.present?
        logger.info "************ refreshing student_schools"
        
        current_student.student_schools.clear

        street_number     = URI.escape(current_student.street_number)
        street_name       = URI.escape(current_student.street_name)
        zipcode           = current_student.zipcode.strip
        grade_level       = current_student.grade_level.to_s.length < 2 ? ('0' + current_student.grade_level.try(:strip)) : current_student.grade_level.try(:strip)
        x_coordinate      = current_student.x_coordinate
        y_coordinate      = current_student.y_coordinate
        sibling_school_id = current_student.sibling_school_id

        # hit the BPS API
        api_schools = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/Schools.svc/GetSchoolChoices?SchoolYear=2014-2015&Grade=#{grade_level}&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}&X=#{x_coordinate}&Y=#{y_coordinate}&SiblingSchList=#{sibling_school_id}")[:List]
        
        if api_schools.present?
          logger.info "*************************** found #{api_schools.count} schools"
          school_coordinates = ''
          school_ids = []
          # loop through the schools returned from the API, find the matching schools in the db,
          # and save the eligibility variables on student_schools
          api_schools.each do |api_school|
            school = School.where(bps_id: api_school[:School]).first
            if school.present? && !school_ids.include?(school.id)
              school_ids << school.id
              school_coordinates += "#{school.latitude},#{school.longitude}|"
              student_school = current_student.student_schools.where(school_id: school.id).first_or_initialize
              student_school.bps_id                     = api_school[:School]
              student_school.tier                       = api_school[:Tier]
              student_school.walk_zone_eligibility      = api_school[:AssignmentWalkEligibilityStatus]
              student_school.transportation_eligibility = api_school[:TransEligible]
              student_school.exam_school                = (api_school[:IsExamSchool] == "0" ? false : true) 
              student_school.save
            end
          end
          
          # hit the Google Distance Matrix API to gather distances, drive times and walk times 
          # between the student's home address to all of his/her eligible schools
          school_coordinates.gsub!(/\|$/,'')
          logger.info "http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=walking&units=imperial&sensor=false"
          walk_info   = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=walking&units=imperial&sensor=false")).get.body, :symbolize_keys => true)
          drive_info  = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=driving&units=imperial&sensor=false")).get.body, :symbolize_keys => true)

          # save distance, walk time and drive time on the student_schools join table
          api_schools.each_with_index do |api_school, i|
            school = School.where(bps_id: api_school[:School]).first
            if school.present?
              student_school = current_student.student_schools.where(school_id: school.id).first_or_initialize
              student_school.distance    = api_school[:StraightLineDistance]
              student_school.walk_time   = walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
              student_school.drive_time  = drive_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
              student_school.save
            end
          end

          current_student.update_attributes(schools_last_updated_at: Time.now)
          return current_student.student_schools.rank(:sort_order)
        end
      else
        return []
      end
    end

    # this method pulls a list of eligible schools from the GetSchoolChoices API, 
    # saves the schools to student_schools, and fetches distance and walk/drive times from the Google Matrix API
    def get_zone_schools
      if current_student.present? && current_student.street_number.present? && current_student.street_name.present? && current_student.zipcode.present?
        logger.info "************ refreshing student_schools"
  
        current_student.student_schools.clear

        zipcode           = current_student.zipcode.strip
        grade_level       = current_student.grade_level.to_s.length < 2 ? ('0' + current_student.grade_level.try(:strip)) : current_student.grade_level.try(:strip)
        x_coordinate      = current_student.x_coordinate
        y_coordinate      = current_student.y_coordinate
        geo_code          = current_student.geo_code
        sibling_school_id = current_student.sibling_school_id

        # hit the BPS API
        api_schools = bps_api_connector("https://apps.mybps.org/WebServiceDiscoverBPSv1.10/schools.svc/GetSchoolInterestList?SchoolYear=2014-2015&Grade=#{grade_level}&ZipCode=#{zipcode}&Geo=#{geo_code}&X=#{x_coordinate}&Y=#{y_coordinate}&SiblingSchList=#{sibling_school_id}")[:List]
        
        if api_schools.present?
          logger.info "*************************** found #{api_schools.count} schools"
          school_coordinates = ''
          school_ids = []
          # loop through the schools returned from the API, find the matching schools in the db,
          # and save the eligibility variables on student_schools
          api_schools.each do |api_school|
            school = School.where(bps_id: api_school[:School]).first
            if school.present? && !school_ids.include?(school.id)
              school_ids << school.id
              school_coordinates += "#{school.latitude},#{school.longitude}|"
              student_school = current_student.student_schools.where(school_id: school.id).first_or_initialize
              student_school.bps_id                     = api_school[:School]
              student_school.tier                       = api_school[:Tier]
              student_school.walk_zone_eligibility      = api_school[:AssignmentWalkEligibilityStatus]
              student_school.transportation_eligibility = api_school[:TransEligible]
              student_school.exam_school                = (api_school[:IsExamSchool] == "0" ? false : true) 
              student_school.save
            end
          end
          
          # hit the Google Distance Matrix API to gather distances, drive times and walk times 
          # between the student's home address to all of his/her eligible schools
          school_coordinates.gsub!(/\|$/,'')
          logger.info "http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=walking&units=imperial&sensor=false"
          walk_info   = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=walking&units=imperial&sensor=false")).get.body, :symbolize_keys => true)
          drive_info  = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=driving&units=imperial&sensor=false")).get.body, :symbolize_keys => true)

          # save distance, walk time and drive time on the student_schools join table
          api_schools.each_with_index do |api_school, i|
            school = School.where(bps_id: api_school[:School]).first
            if school.present?
              student_school = current_student.student_schools.where(school_id: school.id).first_or_initialize
              student_school.distance    = api_school[:StraightLineDistance]
              student_school.walk_time   = walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
              student_school.drive_time  = drive_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
              student_school.save
            end
          end

          current_student.update_attributes(schools_last_updated_at: Time.now)
          return current_student.student_schools.rank(:sort_order)
        end
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
