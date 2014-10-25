class SchoolsController < ApplicationController
  include SchoolsHelper
  layout :layout_selector

  def home
  end


  def index
    if current_user_students.blank?
      render 'home', layout: 'application'
    else
      # Set current_student if it's specified in the params
      if params[:student].present?
        if current_user.present? && current_user.students.find(params[:student]).present?
          session[:current_student_id] = current_user.students.find(params[:student]).id
        elsif Student.where(id: params[:student], session_id: session[:session_id]).present?
          session[:current_student_id] = Student.where(id: params[:student], session_id: session[:session_id]).first.id
        end
      end

      @home_schools = Webservice.home_schools(current_student.grade_level, current_student.street_number, current_student.street_name, current_student.zipcode, current_student.x_coordinate, current_student.y_coordinate, current_student.awc_invitation, current_student.sibling_school_ids)

      if @home_schools.blank?
        flash[:alert] = 'The server responded with an error. Please try your search again later.'
        render 'home', layout: 'application'
      else
        @zone_schools = Webservice.zone_schools(current_student.grade_level, current_student.street_number, current_student.street_name, current_student.zipcode, current_student.x_coordinate, current_student.y_coordinate, current_student.geo_code, current_student.awc_invitation, current_student.sibling_school_ids)
        @ell_schools = Webservice.ell_schools(current_student.grade_level, current_student.address_id, current_student.ell_language)
        @sped_schools = Webservice.sped_schools(current_student, params[:sped])

        get_home_schools(current_student, @home_schools)
        get_zone_schools(current_student, @zone_schools)
        get_ell_schools(current_student, @ell_schools)
        get_sped_schools(current_student, @sped_schools)

        respond_to do |format|
          format.html # index.html.erb
        end
      end
    end
  end

  def compare

  end

  def get_ready

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

    def layout_selector
      case action_name
      when 'home'
        'application'
      when 'print_home_schools'
        'print'
      when 'print_zone_schools'
        'print'
      when 'print'
        'print'
      else
        'schools'
      end
    end

    def get_home_schools(current_student, api_schools)
      get_student_schools(current_student, api_schools, 'home_schools')
    end

    def get_zone_schools(current_student, api_schools)
      get_student_schools(current_student, api_schools, 'zone_schools')
    end

    def get_ell_schools(current_student, api_schools)
      get_student_schools(current_student, api_schools, 'ell_schools')
    end

    def get_sped_schools(current_student, api_schools)
      get_student_schools(current_student, api_schools, 'sped_schools')
    end

    # this method pulls a list of eligible schools from the GetSchoolChoices API,
    # saves the schools to student_schools, and fetches distance and walk/drive times from the Google Matrix API
    def get_student_schools(current_student, api_schools, school_list_type)
      if current_student.present? && current_student.street_number.present? && current_student.street_name.present? && current_student.zipcode.present?

        current_student.student_schools.clear

        # loop through the schools returned from the API, find the matching schools in the db,
        # save the eligibility variables on student_schools, and collect the coordinates for the matrix search, below

        if api_schools.present?
          school_coordinates = ''
          school_ids = []

          api_schools.each do |api_school|
            school = School.where(bps_id: api_school[:School]).first
            if school.present? && !school_ids.include?(school.id)
              school_ids << school.id
              school_coordinates += "#{school.latitude},#{school.longitude}|"
              exam_school = (api_school[:IsExamSchool] == "0" ? false : true)

              student_school = current_student.student_schools.where(school_id: school.id).first_or_initialize
              student_school.update_attributes(school_type: school_list_type, bps_id: api_school[:School], tier: api_school[:Tier], eligibility: api_school[:Eligibility], walk_zone_eligibility: api_school[:AssignmentWalkEligibilityStatus], transportation_eligibility: api_school[:TransEligible], exam_school: exam_school)
            end
          end

          school_coordinates.gsub!(/\|$/,'')
          walk_matrix = get_walk_matrix(current_student, school_coordinates)
          drive_matrix = get_drive_matrix(current_student, school_coordinates)

          # save distance, walk time and drive time on the student_schools join table

          api_schools.each_with_index do |api_school, i|
            school = School.where(bps_id: api_school[:School]).first
            if school.present?
              walk_time = walk_matrix.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)
              drive_time = drive_matrix.try(:[], :rows).try(:[], 0).try(:[], :elements).try(:[], i).try(:[], :duration).try(:[], :text)

              student_school = current_student.student_schools.where(school_id: school.id).first_or_initialize
              student_school.update_attributes(distance: api_school[:StraightLineDistance], walk_time: walk_time, drive_time: drive_time)
            end
          end

          current_student.update_column(:schools_last_updated_at, Time.now)
          current_student.student_schools.rank(:sort_order)
        end
      else
        return []
      end
    end

    def get_walk_times(current_student, school_coordinates)
      MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=walking&units=imperial&sensor=false")).get.body, :symbolize_keys => true)
    end

    def get_drive_times(current_student, school_coordinates)
      MultiJson.load(Faraday.new(url: URI.escape("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{current_student.latitude},#{current_student.longitude}&destinations=#{school_coordinates}&mode=driving&units=imperial&sensor=false")).get.body, :symbolize_keys => true)
    end

end
