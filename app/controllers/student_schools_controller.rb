class StudentSchoolsController < ApplicationController

  def index
    student_schools = Webservice.student_schools(params[:token])

    # {:Token=>"DC74E778-00E3-749A-56E3-001D7EAD42D0", :FirstName=>"Mario", :LastName=>"Haley", :StudentName=>"Haley, MarioStacey", :Grade=>"11", :AddressID=>348690, 
    # :Street=>"GARDNER ST", :Streetno=>"4", :City=>"Allston", :ZipCode=>"02134", :State=>"MA", 
    # :GeoCode=>"801", :Latitude=>"42.3536288141557", :Longitude=>"-71.1316370974287", :X=>"755735.124511719", :Y=>"2954106.35369873"}

    if student_schools && student_schools[:choiceList] && student_schools[:studentInfo]
      student_info = {}
      student_schools[:studentInfo].each_pair do |key, value|
        if value.is_a?(String)
          student_info[key] = value.try(:strip)
        else
          student_info[key] = value
        end
      end
      @student = Student.where(session_id: session[:session_id], 
        token: student_info[:Token],
        first_name: student_info[:FirstName], 
        last_name: student_info[:LastName], 
        grade_level: student_info[:Grade],
        street_number: student_info[:Streetno],
        street_name: student_info[:Street],
        neighborhood: student_info[:City],
        zipcode: student_info[:ZipCode],
        x_coordinate: student_info[:X],
        y_coordinate: student_info[:Y],
        latitude: student_info[:Latitude],
        longitude: student_info[:Longitude],
        addressid: student_info[:AddressID].try(:to_s),
        geo_code: student_info[:GeoCode]
      ).first_or_create
      session[:current_student_id] = @student.id
      @student.set_student_schools!(student_schools[:choiceList])
      @home_schools = @student.home_schools.rank(:sort_order)
    else
      @schools = nil
      @student = nil
    end
    render template: "schools/index"
  end

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

  def star
    @student_school = StudentSchool.find(params[:id])
    respond_to do |format|
      if @student_school.present? && @student_school.update_column(:starred, true)
        format.js { render template: "student_schools/actions/star" }
      end
    end
  end

  def unstar
    @student_school = StudentSchool.find(params[:id])
    respond_to do |format|
      if @student_school.present? && @student_school.update_column(:starred, false)
        format.js { render template: "student_schools/actions/unstar" }
      end
    end
  end

  def add_another
    @current_school = StudentSchool.find(params[:id])
    @current_student = current_student

    respond_to do |format|
      if @current_school.present? && @current_school.update_attributes(sort_order_position: 1, ranked: true)
        @last_school = current_student.home_schools.rank(:sort_order)[5] # need to make sure the schools are ranked in the line above before we can find the 5th school using sort_order
        format.js { render template: "student_schools/actions/add_another" }
      end
    end
  end
end
