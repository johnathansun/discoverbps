class StudentAddressesController < ApplicationController

  def new
    
  end

  def create
    address = response = MultiJson.load(params[:address], :symbolize_keys => true)

    current_student.address_verified = true
    current_student.street_number = address.try(:[], :StreetNum)
    current_student.street_name = address.try(:[], :Street).try(:titleize)
    current_student.neighborhood = address.try(:[], :SectionOfCity)
    current_student.zipcode = address.try(:[], :ZipCode)
    current_student.x_coordinate = address.try(:[], :X)
    current_student.y_coordinate = address.try(:[], :Y)
    current_student.latitude = address.try(:[], :Lat)
    current_student.longitude = address.try(:[], :Lng)
    current_student.geo_code = address.try(:[], :GeoCode)
    current_student.addressid = address.try(:[], :AddressID)
    current_student.ell_cluster = address.try(:[], :ELLCluster)
    current_student.sped_cluster = address.try(:[], :SPEDCluster)
    current_student.zone = address.try(:[], :Zone)

    respond_to do |format|
      if current_student && current_student.update_attributes(params[:student])

        if AWC_GRADES.include?(current_student.grade_level)
          format.js { render template: "student_awc_preferences/new" }
          format.html { redirect_to new_student_awc_preferences_path }
        else
          # if we don't need to ask about AWC, we can set the home schools now
          current_student.set_home_schools!
          format.js { render template: "student_ell_preferences/new" }
          format.html { redirect_to new_student_ell_preferences_path }
        end

      else
        format.js { render template: "students/errors/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end
end