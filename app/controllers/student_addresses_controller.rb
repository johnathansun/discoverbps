class StudentAddressesController < ApplicationController

  def new

  end

  def create
    student = current_student
    address = response = MultiJson.load(params[:address], :symbolize_keys => true)

    student.address_verified = true
    student.street_number = address.try(:[], :StreetNum)
    student.street_name = address.try(:[], :Street).try(:titleize)
    student.neighborhood = address.try(:[], :SectionOfCity)
    student.zipcode = address.try(:[], :ZipCode)
    student.x_coordinate = address.try(:[], :X)
    student.y_coordinate = address.try(:[], :Y)
    student.latitude = address.try(:[], :Lat)
    student.longitude = address.try(:[], :Lng)
    student.geo_code = address.try(:[], :GeoCode)
    student.addressid = address.try(:[], :AddressID)
    student.ell_cluster = address.try(:[], :ELLCluster)
    student.sped_cluster = address.try(:[], :SPEDCluster)
    student.zone = address.try(:[], :Zone)

    respond_to do |format|
      if student.save!

        if AWC_GRADES.include?(student.grade_level)
          format.js { render template: "student_awc_preferences/new" }
          format.html { redirect_to new_student_awc_preferences_path }
        else
          # if we don't need to ask about AWC, we can set the home schools now
          student.set_home_schools!
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
