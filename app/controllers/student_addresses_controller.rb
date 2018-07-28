class StudentAddressesController < ApplicationController

  def new
    if current_student
      street_number = current_student.street_number
      street_name   = current_student.street_name
      zipcode       = current_student.zipcode

      api_response = Webservice.address_matches(street_number, street_name, zipcode)
      @addresses = api_response.try(:[], :List)
      @errors = api_response.try(:[], :Error).try(:[], 0)
    else
      redirect_to root_url
    end
  end

  def create
    student = current_student
    address = response = MultiJson.load(params[:address], :symbolize_keys => true)

    student.address_verified = true
    student.street_number = address.try(:[], :Streetno)
    student.street_name = address.try(:[], :Street).try(:titleize)
    student.neighborhood = address.try(:[], :City)
    student.zipcode = address.try(:[], :Zip)
    student.x_coordinate = address.try(:[], :CityOfBostonX)
    student.y_coordinate = address.try(:[], :CityOfBostonY)
    student.latitude = address.try(:[], :Latitude)
    student.longitude = address.try(:[], :Longitude)
    student.geo_code = address.try(:[], :Geo)
    student.addressid = address.try(:[], :AddressID)
    student.ell_cluster = address.try(:[], :ELLCluster)
    student.sped_cluster = address.try(:[], :SPEDCluster)
    student.zone = address.try(:[], :HZone)

    respond_to do |format|
      if student.save!

        if AWC_GRADES.include?(student.grade_level)
          format.js { render template: "student_awc_preferences/new" }
          format.html { redirect_to new_student_awc_preference_path }
        else
          # if we don't need to ask about AWC, we can set the home schools now
          student.set_home_schoolsf
          format.js { render template: "student_ell_preferences/new" }
          format.html { redirect_to new_student_ell_preference_path }
        end

      else
        format.js { render template: "students/errors/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end
end
