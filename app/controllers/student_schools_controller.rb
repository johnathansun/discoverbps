class StudentSchoolsController < ApplicationController

  def star
    @student_school = StudentSchool.find(params[:id])
    respond_to do |format|
      if @student_school.present? && @student_school.update_column(:starred, true)
        format.js { render template: "schools/actions/star" }
      end
    end
  end

  def unstar
    @student_school = StudentSchool.find(params[:id])
    respond_to do |format|
      if @student_school.present? && @student_school.update_column(:starred, false)
        format.js { render template: "schools/actions/unstar" }
      end
    end
  end
end
