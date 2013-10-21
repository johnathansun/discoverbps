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
      # Find the current_student if it's specified in the params
      if params[:student].present? 
        if current_user.present? && current_user.students.where(first_name: params[:student]).first.present?
          session[:current_student_id] = current_user.students.where(first_name: params[:student]).first.id
        elsif Student.where(first_name: params[:student], session_id: session[:session_id]).present?
          session[:current_student_id] = Student.where(first_name: params[:student], session_id: session[:session_id]).first.id
        end
      end

      # Hit the BPS API if the student has no saved school_choices, or if the cache is stale (> 24 hours)
      if current_student.api_school_choices.blank? || current_student.api_school_choices_created_at.blank? || current_student.api_school_choices_created_at < Time.now.yesterday
        if current_student.street_number.present? && current_student.street_name.present? && current_student.zipcode.present?
          street_number = URI.escape(current_student.street_number)
          street_name   = URI.escape(current_student.street_name)
          zipcode       = current_student.zipcode.strip
          grade_level   = current_student.grade_level.to_s.length < 2 ? ('0' + current_student.grade_level.try(:strip)) : current_student.grade_level.try(:strip)

          eligible_schools = bps_api_connector("https://apps.mybps.org/schooldata/schools.svc/GetSchoolChoices?SchoolYear=2013-2014&Grade=#{grade_level}&StreetNumber=#{street_number}&Street=#{street_name}&ZipCode=#{zipcode}")[:List]

          @eligible_schools = []
          
          # Add eligibility attributes to schools
          @school_coordinates = ''      
          eligible_schools.each do |school|
            s = School.where(bps_id: school[:School]).first
            if s.present?
              s.tier = school[:Tier]
              s.walk_zone_eligibility = school[:AssignmentWalkEligibilityStatus]
              s.transportation_eligibility = school[:TransEligible]
              @school_coordinates += "#{s.latitude},#{s.longitude}|"
              @eligible_schools << s
            end
          end

          current_student.update_attributes(api_school_choices: @eligible_schools)
        else
          @eligible_schools = []
        end
      
      # Use the current_student's saved list of schools if they're saved
      elsif current_student.api_school_choices.present?
        @eligible_schools = current_student.api_school_choices
      else
        @eligible_schools = []        
      end

      # Add walk and drive times
      if @eligible_schools.present?
        @school_coordinates.gsub!(/\|$/,'')
        @walk_info = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{@school_coordinates}&mode=walking&units=imperial&sensor=false")).get.body, :symbolize_keys => true)
        @drive_info = MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{@school_coordinates}&mode=driving&units=imperial&sensor=false")).get.body, :symbolize_keys => true)

        @eligible_schools.each_with_index do |school, i|
          school.walk_time = @walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
          school.drive_time = @drive_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
          school.distance = @walk_info.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :distance).try(:[], :text)
        end
      end

      # Sort eligible schools by session sort order if it exists
        @sorted_eligible_schools = []
      if current_user.present? && current_user.school_rankings.where(student_id: current_student.id).present?
        search_ids = @eligible_schools.collect {|x| x.bps_id.to_s}
        ranked_ids = current_user.school_rankings.where(student_id: current_student.id).first.sorted_school_ids
        combined_ids = (ranked_ids + (search_ids - ranked_ids)).flatten
        combined_ids.each do |bps_id|
          school = @eligible_schools.select {|x| x.bps_id.to_s == bps_id}
          if school.present?
            @sorted_eligible_schools << school.first
          end
        end
      elsif session["student_#{current_student.id}_school_ids".to_sym].present?
        search_ids = @eligible_schools.collect {|x| x.bps_id.to_s}
        ranked_ids = session["student_#{current_student.id}_school_ids".to_sym]
        combined_ids = (ranked_ids + (search_ids - ranked_ids)).flatten
        combined_ids.each do |bps_id|
          school = @eligible_schools.select {|x| x.bps_id.to_s == bps_id}
          if school.present?
            @sorted_eligible_schools << school.first
          end
        end
      else
        @sorted_eligible_schools = @eligible_schools
      end

      # current_student.school_ids.clear
      # current_student.school_ids = @sorted_eligible_schools.collect {|x| x.id}

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
      school_ids = params[:school].flatten
      if current_user.present?
        school_ranking = SchoolRanking.where(user_id: current_user.id, student_id: current_student_id).first_or_create
        school_ranking.update_attributes(sorted_school_ids: school_ids)
      else
        session["student_#{session[:current_student_id]}_school_ids".to_sym] = school_ids
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
