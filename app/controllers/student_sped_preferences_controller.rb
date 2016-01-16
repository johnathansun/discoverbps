class StudentSpedPreferencesController < ApplicationController

  def new

  end

  def create

    respond_to do |format|
      if current_student && current_student.update_attributes(params[:student])

        if current_student.sped_needs == true
          current_student.set_sped_schools
        end

        format.html { redirect_to schools_path}
        format.js { render :js => "window.location = '/schools'" }

      else
        format.js { render template: "student_sped_preferences/new" }
        flash[:alert] = 'There were problems with your search. Please complete the required fields and try again.'
        format.html { redirect_to root_url }
      end
    end
  end

end
