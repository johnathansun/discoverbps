class ChoiceSchoolsController < ApplicationController
  include ApplicationHelper
  include SchoolsHelper
  before_filter :redirect_if_token_is_blank, except: [:index]
  before_filter :get_or_set_student, except: [:index, :verify, :send_verification, :confirmation, :authenticate]
  layout "choice_schools"

  def index
  end

  def verify
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
    if @student.starred_schools.present?
      @choice_schools = @student.starred_schools.all
      @student.choice_schools.all.each do |school|
        @choice_schools << school unless @choice_schools.include?(school)
      end
    else
      @choice_schools = @student.choice_schools
    end
  end

  def order
    if @student.choice_schools.blank?
      redirect_to choice_schools_path(token: params[:token]), alert: "There were no schools that matched your search. Please try again."
    else
      if schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
        @choice_schools = schools
      elsif schools = @student.starred_schools.all
        @choice_schools = schools
      else
        @choice_schools = []
      end

      @student.choice_schools.includes(:school).order("schools.name").all.each do |student_school|
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
    @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end

  def submit
    @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }

    if @choice_schools.blank?
      redirect_to order_choice_schools_path(token: params[:token]), alert: "Please rank one or more schools and then submit your list:"
    else
      payload = []
      @choice_schools.each do |student_school|
        payload << { "CallID" => student_school.call_id, "ProgramCode" => student_school.program_code, "SchoolID" => student_school.school.bps_id, "Rank" => student_school.choice_rank, "CreatedDateTime" => "", "SchoolRankID" => "" }
      end
      Webservice.save_choice_rank(payload)
      redirect_to success_choice_schools_path
    end
  end

  def success
    @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end

  private

  def redirect_if_token_is_blank
    if params[:token].blank?
      redirect_to choice_schools_path, alert: "Please access this site from a valid URL found in your invitation email."
    end
  end

  def get_or_set_student
    if student = Student.where(token: params[:token]).first
      @student = student
    elsif student = Student.save_student_and_choice_schools(params[:token], session[:session_id])
      @student = student
    else
      redirect_to choice_schools_path, alert: "We couldn't find a student using the URL you provided. Please check the link and try again."
    end
  end

end
