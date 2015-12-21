class ChoiceSchoolsController < ApplicationController
  include ApplicationHelper
  include SchoolsHelper
  layout "choice_schools"

  def index
  end

  def verify
    if params[:token].present?
    end
  end

  def send_verification
    if params[:contact_method].blank?
      redirect_to verify_choice_schools_path(token: params[:token]), alert: "Please choose a contact method:"
    else
      redirect_to confirmation_choice_schools_path(token: params[:token], contact_method: params[:contact_method])
    end
  end

  def confirmation

  end

  def authenticate
    if params[:confirmation_code].blank?
      redirect_to confirmation_choice_schools_path(token: params[:token]), alert: "Please enter your confirmation code:"
    else
      redirect_to list_choice_schools_path(token: params[:token])
    end
  end

  def list
    if current_student.try(:token) == params[:token]
      student = current_student
    else
      student = Student.save_student_and_choice_schools(params[:token], session[:session_id])
    end
    if student.present?
      session[:student_id] = student.id
      @choice_schools = student.choice_schools.rank(:sort_order)
    else
      @choice_schools = nil
    end
  end

  def order
    if current_user_students.blank?
      flash[:alert] = 'There were no schools that matched your search. Please try again.'
      redirect_to root_url
    else
      current_student.update_column(:step, 3) if current_student.step < 3
      @matching_school_ids = current_user_students.collect {|x| x.student_schools.collect {|y| y.bps_id}}.inject(:&)

      @choice_schools = current_student.choice_schools.includes(:school).order("schools.name")

      if @choice_schools.blank?
        flash[:alert] = 'There were no schools that matched your search. Please try again.'
        redirect_to root_url
      else
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def rank
    if params[:schools].blank? || params[:schools].values.all? {|x| x.blank?}
      redirect_to order_choice_schools_path(token: params[:token]), alert: "Please rank one or more schools and then submit your list:"
    else
      params[:schools].each do |id, rank|
        if rank.present?
          school = StudentSchool.find(id)
          school.update_column(:choice_rank, rank)
        end
      end
      redirect_to summary_choice_schools_path
    end
  end

  def summary
    @choice_schools = current_student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end

  def submit
    @choice_schools = current_student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }

    if @choice_schools.blank?
      redirect_to order_choice_schools_path(token: params[:token]), alert: "Please rank one or more schools and then submit your list:"
    else
      payload = []
      @choice_schools.each do |student_school|
        payload << { "CallID" => student_school.call_id, "ProgramCode" => student_school.program_code, "SchoolID" => student_school.school.bps_id, "Rank" => student_school.choice_rank, "CreatedDateTime" => "", "SchoolRankID" => "" }
      end
      Webservice.submit_ranked_choices(payload)
      redirect_to success_choice_schools_path
    end
  end

  def success
    @choice_schools = current_student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end



end
