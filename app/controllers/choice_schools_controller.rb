class ChoiceSchoolsController < ApplicationController
  include ApplicationHelper
  include SchoolsHelper

  before_filter :redirect_if_student_token_invalid, only: [:verify, :confirmation]
  before_filter :find_student_by_session_token, only: [:list, :order, :summary, :submit, :success]
  before_filter :redirect_if_session_token_invalid, only: [:list, :order, :summary, :submit, :success]

  layout "choice_schools"

  # GET
  def index
  end

  # GET
  def verify
    parent_hash = Webservice.get_parent(params[:token])
    @email_1 = parent_hash[:emailAddress1]
    @email_2 = parent_hash[:emailAddress2]
  end

  # POST
  def send_verification
    if params[:contact_method].blank? || params[:token].blank?
      redirect_to verify_choice_schools_path(token: params[:token]), alert: "Please choose a contact method:"
    else
      Webservice.generate_passcode(params[:token], params[:contact_method]) # BPS sends the code to applicant
      redirect_to confirmation_choice_schools_path(token: params[:token], contact_method: params[:contact_method])
    end
  end

  # GET
  def confirmation
  end

  # POST
  def authenticate
    if params[:passcode].blank? || params[:token].blank?
      redirect_to confirmation_choice_schools_path(token: params[:token]), alert: "Please enter your confirmation code:"
    else
      session_token = Webservice.generate_session_token(params[:token], params[:passcode])
      if session_token # has no errors
        student = Student.save_choice_student!(params[:token], session_token, session[:session_id])
        if student # is valid
          choice_schools = Webservice.get_choice_schools(session_token)
          student.set_choice_schools!(choice_schools)
          redirect_to list_choice_schools_path(token: session_token)
        else
          Rails.logger.info "******************* didn't get a valid student"
          redirect_to confirmation_choice_schools_path(token: params[:token]), alert: "Please try again"
        end
      else
        Rails.logger.info "******************* didn't get a valid session token"
        redirect_to confirmation_choice_schools_path(token: params[:token]), alert: "Please try again"
      end
    end
  end

  # GET
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

  # GET
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

  # POST
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

  # GET
  def summary
    @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end

  # POST
  def submit
    @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }

    if @choice_schools.blank?
      redirect_to order_choice_schools_path(token: params[:token]), alert: "Please rank one or more schools and then submit your list:"
    else
      payload = []
      @choice_schools.each do |student_school|
        payload << { "CallID" => student_school.call_id, "ProgramCode" => student_school.program_code, "SchoolID" => student_school.school.bps_id, "Rank" => student_school.choice_rank, "CreatedDateTime" => "", "SchoolRankID" => "" }
      end
      Webservice.save_choice_rank(params[:token], payload)
      redirect_to success_choice_schools_path(token: params[:token])
    end
  end

  # GET
  def success
    @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end

  private

  def redirect_if_student_token_invalid
    if params[:token].blank? || Webservice.get_student(params[:token]).try(:[], :Token) != params[:token]
      redirect_to choice_schools_path(token: params[:token]), alert: "Please access this site from a valid URL found in your invitation email."
    end
  end

  def redirect_if_session_token_invalid
    # finding a student with the session token only tells us whether one has been
    # created in the past. we also need to verify that the token isn't expired
    if params[:token].blank? || @student.blank?
      redirect_to verify_choice_schools_path(token: @student.try(:token)), alert: "Please access this site from a valid URL found in your invitation email."
    elsif Webservice.validate_session_token(params[:token]).try(:[], :messageContent) != "Session token is valid"
      redirect_to verify_choice_schools_path(token: @student.try(:token)), alert: "Your session token has expired. Please revalidate your account."
    end
  end

  def find_student_by_session_token
    # see if we can find a student with this token, which should have been
    # saved on the authenticate method. if not, go back and get one
    @student = Student.where(session_token: params[:token]).first
  end
end
