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
    unless current_student.present? && current_student[:token] == params[:token]
      student = Student.save_student_and_choice_schools(params[:token], session[:session_id])
      session[:student_id] = student.id
    end
    if current_student.present? && current_student[:token] == params[:token]
      if current_student.starred_schools.present?
        @choice_schools = current_student.starred_schools.all
        current_student.choice_schools.all.each do |school|
          @choice_schools << school unless @choice_schools.include?(school)
        end
      else
        @choice_schools = current_student.choice_schools
      end
    else
      @choice_schools = nil
    end
  end

  def order
    if current_student.choice_schools.blank?
      flash[:alert] = 'There were no schools that matched your search. Please try again.'
      redirect_to choice_schools_path(token: params[:token])
    else
      if schools = current_student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
        @choice_schools = schools
      elsif schools = current_student.starred_schools.all
        @choice_schools = schools
      else
        @choice_schools = []
      end

      current_student.choice_schools.includes(:school).order("schools.name").all.each do |student_school|
        @choice_schools << student_school unless @choice_schools.include?(student_school)
      end

      respond_to do |format|
        format.html
      end
    end
  end

  def rank
    if params[:schools].blank? || params[:schools].values.all? {|x| x.blank?}
      redirect_to order_choice_schools_path(token: params[:token]), alert: "Please rank one or more schools and then submit your list:"
    else
      rankings = params[:schools].values.select {|x| x.present?}
      properly_formatted = rankings.map {|x| x.try(:to_i)}.sort == (rankings.map {|x| x.try(:to_i)}.sort[0]..rankings.map {|x| x.try(:to_i)}.sort[-1]).to_a rescue false

      if properly_formatted
        params[:schools].each do |id, rank|
          if rank.present?
            school = StudentSchool.find(id)
            school.update_column(:choice_rank, rank)
          end
        end
        redirect_to summary_choice_schools_path(token: params[:token])
      else
        redirect_to order_choice_schools_path(token: params[:token]), alert: "There are errors with your sort order. Please ensure that your rankings are sequential and start with number one:"
      end
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
