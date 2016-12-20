class ChoiceSchoolsController < ApplicationController
  include ApplicationHelper
  include SchoolsHelper

  before_filter :redirect_if_student_token_invalid, only: [:verify, :confirmation]
  before_filter :find_student_by_session_token, only: [:list, :order, :summary, :submit, :success]
  before_filter :redirect_if_session_token_invalid, only: [:list, :order, :summary, :submit, :success]

  layout "choice_schools"

  # GET
  def index
    @notifications = Notification.where(school_choice_pages: true)
  end

  # GET
  def verify
    parent_response = Webservice.get_parent(params[:token])
    @email_1 = parent_response[:emailAddress1]
    @email_2 = parent_response[:emailAddress2]
    session[:caseid] = params[:caseid]
  end

  # POST
  def send_verification
    if params[:contact_method].blank? || params[:token].blank?
      redirect_to verify_choice_schools_path(token: params[:token]), alert: "Please choose a contact method:"
    else
      passcode_response = Webservice.generate_passcode(params[:token], params[:contact_method]) # BPS sends the code to applicant
      if passcode = passcode_response.try(:[], :passcode)
        redirect_to confirmation_choice_schools_path(token: params[:token], caseid: params[:caseid], contact_method: params[:contact_method])
      else
        redirect_to verify_choice_schools_path(token: params[:token], caseid: params[:caseid]), alert: "Please choose a contact method:"
      end
    end
  end

  # GET
  def confirmation
  end

  # POST
  def authenticate
    if params[:passcode].blank? || params[:token].blank?
      redirect_to confirmation_choice_schools_path(token: params[:token], caseid: params[:caseid]), alert: "Please enter your confirmation code:"
    else
      session_token_response = Webservice.generate_session_token(params[:token], params[:passcode])
      if session_token = session_token_response.try(:[], :sessionToken)       
        if student = Student.save_choice_student_and_schools(params[:token], session_token, session[:session_id], session[:caseid])
          session[:current_student_id] = student.id
          session[:session_token] = session_token
          redirect_to list_choice_schools_path
        else
          Rails.logger.info "******************* didn't get a valid choice_student_and_schools"
          redirect_to confirmation_choice_schools_path(token: params[:token], caseid: params[:caseid]), alert: "Please try again:"
        end
      else
        Rails.logger.info "******************* didn't get a valid session token"
        redirect_to confirmation_choice_schools_path(token: params[:token], caseid: params[:caseid]), alert: "Please try again:"
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
    @notifications = Notification.where(school_choice_pages: true)

    if @student.choice_schools.blank?
      redirect_to choice_schools_path, alert: "There were no schools that matched your search. Please try again."
    elsif Webservice.get_student(@student.token).try(:[], :HasRankedChoiceSubmitted) == true
      redirect_to success_choice_schools_path, alert: "You have already submitted your school choice list for the current school year. Your choice list is as follows:"
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
    if params[:schools].blank? || params[:schools].values.all? {|x| x.blank?} || params[:schools].values.select {|x| x.present?}.count < 3
      redirect_to order_choice_schools_path, alert: "Please rank three or more schools and then submit your list"
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
        redirect_to summary_choice_schools_path
      else
        redirect_to order_choice_schools_path, alert: "Please ensure that your rankings are in order and start with '1'"
      end
    end
  end

  # GET
  def summary
    if Webservice.get_student(@student.token).try(:[], :HasRankedChoiceSubmitted) == true
      redirect_to success_choice_schools_path, alert: "You have already submitted your school choice list for the current school year. Your choice list is as follows:"
    else
      @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
    end
  end

  # POST
  def submit
    @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }

    if @choice_schools.blank?
      redirect_to order_choice_schools_path, alert: "Please rank one or more schools and then submit your list"
    elsif params[:parent_name].blank?
      redirect_to summary_choice_schools_path, alert: "Please type your full name into the text box below to attest that:"
    else
      payload = []
      @choice_schools.each do |student_school|
        payload << { "CallID" => student_school.call_id, "ProgramCode" => student_school.program_code, "SchoolID" => student_school.school.bps_id, "Rank" => student_school.choice_rank, "CreatedDateTime" => "", "SchoolRankID" => "" }
      end
      @student.update_attributes(ranked: true, ranked_at: Time.now, parent_name: params[:parent_name])
      Webservice.save_ranked_choices(session[:session_token], payload, params[:parent_name])
      redirect_to success_choice_schools_path
    end
  end

  # GET
  def success
    if @student.token.present?
      @choice_schools = Webservice.get_ranked_choices(@student.token)
    else
      @choice_schools = []
    end
    Rails.logger.info "*********************** success page schools = #{@choice_schools}"
    # @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end

  private

  def redirect_if_student_token_invalid
    if params[:token].blank? || Webservice.get_student(params[:token]).try(:[], :Token) != params[:token] || params[:caseid].blank?
      redirect_to choice_schools_path(token: params[:token]), alert: "Please access this site from a valid URL found in your invitation email."
    end
  end

  def redirect_if_session_token_invalid
    # finding a student with the session token only tells us whether one has been
    # created in the past. we also need to verify that the token isn't expired
    if session[:session_token].blank? || @student.blank? 
      redirect_to verify_choice_schools_path(token: @student.try(:token)), alert: "Please access this site from a valid URL found in your invitation email."
    elsif Webservice.validate_session_token(session[:session_token]).try(:[], :messageContent) != "Session token is valid"
      redirect_to verify_choice_schools_path(token: @student.try(:token)), alert: "Your session token has expired. Please revalidate your account."
    end
  end

  def find_student_by_session_token
    # see if we can find a student with this token, which should have been
    # saved on the authenticate method. if not, go back and get one
    @student = Student.where(session_token: session[:session_token]).first
  end
end
