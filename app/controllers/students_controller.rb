class StudentsController < ApplicationController

  def index
  end

  def create

    if params[:student].present? && params[:student][:grade_level].present? && params[:student][:street_number].present? && params[:student][:street_name].present? && params[:student][:zipcode].present?

      first_name    = params[:student][:first_name]
      last_name     = params[:student][:last_name]
      grade_level   = params[:student][:grade_level]
      street_number = params[:student][:street_number]
      street_name   = params[:student][:street_name]
      zipcode       = params[:student][:zipcode]

      street_number_numeric = (true if Integer(street_number) rescue false)
      zipcode_length = (zipcode.length == 5)

      if street_number_numeric && zipcode_length
        @student = get_or_set_student(current_user, first_name, last_name, grade_level)

        params[:student][:sibling_school_ids] = School.where("name IN (?)", params[:student][:sibling_school_names].try(:compact).try(:reject, &:empty?)).collect {|x| x.bps_id}.uniq

        api_response = Webservice.address_matches(street_number, street_name, zipcode)
        @addresses = api_response.try(:[], :List)
        @errors = api_response.try(:[], :Error).try(:[], 0)
      end
    end

    respond_to do |format|

      if @addresses.present? && @student.present? && @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id
        format.js { render template: "students/address/addresses" }
        format.html { redirect_to addresses_student_path(@student)}
      else
        if api_response.present?
          if @addresses.blank?
            if @errors.present?
              @error_message = @errors
              flash[:alert] = "There were problems with your search. Please enter the required fields and try again."
            else
              @error_message = "We couldn't find any addresses in Boston that match your search. Please try again."
              flash[:alert] = "We couldn't find any addresses in Boston that match your search. Please try again."
            end
          end
        elsif street_number_numeric == false
          @error_message = "Street number must be a number. Please try again."
          flash[:alert] = "Street number must be a number. Please try again."
        elsif zipcode_length == false
          @error_message = "Zip code must be a 5-digit number. Please try again."
          flash[:alert] = "Zip code must be a 5-digit number. Please try again."
        else
          @error_message = "Please enter the required search fields and try again."
          flash[:alert] = "Please enter the required search fields and try again."
        end

        format.js { render template: "students/errors/errors" }
        format.html { redirect_to root_url }
      end
    end
  end

  def update
    @student = Student.find(params[:id])

    street_number = params[:student].try(:[], :street_number)
    street_name   = params[:student].try(:[], :street_name)
    zipcode       = params[:student].try(:[], :zipcode)

    api_response = Webservice.address_matches(street_number, street_name, zipcode)
    @addresses = api_response.try(:[], :List)
    @errors = api_response.try(:[], :Error).try(:[], 0)

    respond_to do |format|
      if @addresses.present? && @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id

        format.js { render template: "students/address/addresses" }
        format.html { redirect_to addresses_student_path(@student)}
      else
        if @addresses.blank?
          if @errors.present?
            @error_message = @errors
          else
            @error_message = "We couldn't find any addresses in Boston that match your search. Please try again."
          end
        end
        format.js { render template: "students/errors/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

  # ADDRESS DIALOG BOX

  def addresses
    @student = Student.find(params[:id])

    street_number = @student.street_number
    street_name   = @student.street_name
    zipcode       = @student.zipcode

    api_response = Webservice.address_matches(street_number, street_name, zipcode)
    @addresses = api_response.try(:[], :List)
    @errors = api_response.try(:[], :Error).try(:[], 0)
  end

  def verify_address
    @student = Student.find(params[:id])
    address = response = MultiJson.load(params[:address], :symbolize_keys => true)

    @student.address_verified = true
    @student.street_number = address.try(:[], :StreetNum)
    @student.street_name = address.try(:[], :Street).try(:titleize)
    @student.neighborhood = address.try(:[], :SectionOfCity)
    @student.zipcode = address.try(:[], :ZipCode)
    @student.x_coordinate = address.try(:[], :X)
    @student.y_coordinate = address.try(:[], :Y)
    @student.latitude = address.try(:[], :Lat)
    @student.longitude = address.try(:[], :Lng)
    @student.geo_code = address.try(:[], :GeoCode)
    @student.addressid = address.try(:[], :AddressID)
    @student.ell_cluster = address.try(:[], :ELLCluster)
    @student.sped_cluster = address.try(:[], :SPEDCluster)
    @student.zone = address.try(:[], :Zone)

    respond_to do |format|
      if @student.update_attributes(params[:student])

        if AWC_GRADES.include?(@student.grade_level)
          format.html { redirect_to awc_student_path(@student)}
          format.js { render template: "students/awc/awc" }
        else
          # if we don't need to ask about AWC, we can set the home schools now
          @student.set_home_schools!
          format.html { redirect_to ell_student_path(@student)}
          format.js { render template: "students/ell/ell" }
        end

      else
        format.js { render template: "students/errors/errors" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

  # AWC DIALOG BOX

  def awc
    @student = Student.find(params[:id])
  end

  def set_awc
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])

        # the home schools call must always preceed zone schools
        @student.set_home_schools!

        format.html { redirect_to ell_student_path(@student)}
        format.js { render template: "students/ell/ell" }
      else
        format.js { render template: "students/awc/awc" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

  # ELL DIALOG BOX

  def ell
    @student = Student.find(params[:id])
  end

  def set_ell
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])

        if zone_school_grades.include?(@student.grade_level)
          @student.set_zone_schools!
        end

        unless @student.ell_language.blank?
          @student.set_ell_schools!
        end

        format.html { redirect_to sped_student_path(@student)}
        format.js { render template: "students/sped/sped" }
      else
        format.js { render template: "students/ell/ell" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end


  # SPED DIALOG BOX

  def sped
    @student = Student.find(params[:id])
  end

  def set_sped
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])

        if @student.sped_needs == true
          @student.set_sped_schools!
        end

        format.html { redirect_to schools_path}
        format.js { render :js => "window.location = '/schools'" }

      else
        format.js { render template: "students/sped/sped" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end


  def destroy
    @student = Student.find(params[:id])
    @student.destroy
    session[:current_student_id] = nil

    respond_to do |format|
      format.html { redirect_to root_url }
    end
  end

  def save_preference
    current_student.preferences.clear
    if params.try(:[], :student).try(:[], :preference_ids).present?
      params[:student][:preference_ids].each do |name|
        current_student.preferences << Preference.where(name: name)
      end
    end
    render nothing: true
  end

  def remove_notification
    logger.info params
    if session[:removed_notifications].present?
      session[:removed_notifications] << params[:notification_id]
      session[:removed_notifications].uniq!
    else
      session[:removed_notifications] = []
      session[:removed_notifications] << params[:notification_id]
      session[:removed_notifications].uniq!
    end
    render nothing: true
  end

  private

  def get_or_set_student(current_user, first_name, last_name, grade_level)
    if current_user.present?
      if first_name.present? && last_name.present?
        Student.where(user_id: current_user.id, first_name: first_name, last_name: last_name).first_or_initialize
      elsif first_name.present?
        Student.where(user_id: current_user.id, first_name: first_name).first_or_initialize
      else
        Student.where(user_id: current_user.id, grade_level: grade_level).first_or_initialize
      end
    elsif session[:session_id].present?
      if first_name.present? && last_name.present?
        Student.where(session_id: session[:session_id], first_name: first_name, last_name: last_name).first_or_initialize
      elsif first_name.present?
        Student.where(session_id: session[:session_id], first_name: first_name).first_or_initialize
      else
        Student.where(session_id: session[:session_id], grade_level: grade_level).first_or_initialize
      end
    else
      nil
    end
  end

end
