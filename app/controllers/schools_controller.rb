class SchoolsController < ApplicationController
  include SchoolsHelper
  layout :layout_selector

  def index
    if current_user_students.blank?
      redirect_to root_url
    else
      # Set current_student if it's specified in the params
      if params[:student].present?
        if current_user.present? && current_user.students.find(params[:student]).present?
          session[:current_student_id] = current_user.students.find(params[:student]).id
        elsif Student.where(id: params[:student], session_id: session[:session_id]).present?
          session[:current_student_id] = Student.where(id: params[:student], session_id: session[:session_id]).first.id
        end
      end

      @home_schools = current_student.home_schools
      @zone_schools = current_student.zone_schools
      @ell_schools = current_student.ell_schools
      @sped_schools = current_student.sped_schools

      if @home_schools.blank?
        flash[:alert] = 'There were no schools that matched your search. Please try again.'
        redirect_to root_url
      else
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def compare
    if current_user_students.blank?
      flash[:alert] = 'There were no schools that matched your search. Please try again.'
      redirect_to root_url
    else
      @matching_school_ids = current_user_students.collect {|x| x.student_schools.collect {|y| y.bps_id}}.inject(:&)

      respond_to do |format|
        format.html
      end
    end
  end

  def get_ready

  end

  # POST
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

  private

    def layout_selector
      case action_name
      when 'print_home_schools'
        'print'
      when 'print_zone_schools'
        'print'
      when 'print'
        'print'
      else
        'schools'
      end
    end

end
