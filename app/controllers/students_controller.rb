class StudentsController < ApplicationController

  def new
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

        api_response = Webservice.get_address_matches(street_number, street_name, zipcode)
        @addresses = api_response.try(:[], :List)
        @errors = api_response.try(:[], :Error).try(:[], 0)
      end
    end

    respond_to do |format|

      if @addresses.present? && @student.present? && @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id
        format.js { render template: "student_addresses/new" }
        format.html { redirect_to new_student_address_path }
      else
        if api_response.present?
          if @errors.present?
            @error_message = @errors
            flash[:alert] = "There were problems with your search. Please enter the required fields and try again."
          else
            @error_message = "We couldn't find any addresses in Boston that match your search. Please try again."
            flash[:alert] = "We couldn't find any addresses in Boston that match your search. Please try again."
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

    api_response = Webservice.get_address_matches(street_number, street_name, zipcode)
    @addresses = api_response.try(:[], :List)
    @errors = api_response.try(:[], :Error).try(:[], 0)

    respond_to do |format|
      if @addresses.present? && @student.update_attributes(params[:student])
        session[:current_student_id] = @student.id

        format.js { render template: "student_addresses/new" }
        format.html { redirect_to new_student_address_path }
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

  def swtich_current
    session[:student_id] = params[:id]
    redirect_to(:back)
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
