class StudentSchoolsController < ApplicationController

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
