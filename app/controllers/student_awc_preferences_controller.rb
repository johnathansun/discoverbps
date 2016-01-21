class StudentAwcPreferencesController < ApplicationController

  def new
    if current_student.blank?
      redirect_to root_url
    end
  end

  def create
    respond_to do |format|
      if current_student && current_student.update_attributes(params[:student])

        # the home schools call must always preceed zone schools
        current_student.set_home_schools

        format.js { render template: "student_ell_preferences/new" }
        format.html { redirect_to new_student_ell_preferences_path }
      else
        format.js { render template: "student_awc_preferences/new" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

end
