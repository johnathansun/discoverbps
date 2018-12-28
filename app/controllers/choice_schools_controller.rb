class ChoiceSchoolsController < ApplicationController
  include ApplicationHelper
  include SchoolsHelper

  before_filter :redirect_if_student_token_invalid, only: [:verify, :confirmation]
  before_filter :find_student_by_session_token, only: [:list, :order, :summary, :submit, :success]
  before_filter :redirect_if_session_token_invalid, only: [:list, :order, :summary, :submit, :success]

  layout "choice_schools"

  # GET
  def index
    @RoundEndDate = Webservice.get_student(params[:token], params[:caseid]).try(:[], :RoundEndDate)   
    @notifications = Notification.where(school_choice_pages: true)
    session[:caseid] = params[:caseid]
  end

  # GET
  def verify
    parent_response = Webservice.get_parent(params[:token])
    @email_1 = parent_response[:emailAddress1]
    @email_2 = parent_response[:emailAddress2]
    if session[:caseid]
      session[:caseid] = params[:caseid]       
    end  
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
  #710456
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
      @student.choice_schools.all.order(:sort_order).each do |school|
        @choice_schools << school unless @choice_schools.include?(school)
      end
    else
      @choice_schools = @student.choice_schools.order(:sort_order)
    end   
  end

  # GET
  def order
    @notifications = Notification.where(school_choice_pages: true)
    @studentResponse = Webservice.get_student(@student.token, session[:caseid])
    if @student.choice_schools.blank?
      redirect_to choice_schools_path, alert: "There were no schools that matched your search. Please try again."
    elsif @studentResponse.try(:[], :HasRankedChoiceSubmitted) == true
      redirect_to success_choice_schools_path, alert: "You have already submitted your school choice list for the current school year. Your choice list is as follows:"
    elsif @studentResponse.try(:[], :RoundEndDate).present? && Time.now > DateTime.parse(@studentResponse.try(:[], :RoundEndDate))       
      @RoundEndDate = @studentResponse.try(:[], :RoundEndDate) 
      redirect_to choice_schools_path(token: @student.token, caseid: session[:caseid]), alert: " As of #{Date.parse(@RoundEndDate).strftime("%B %d %Y")}, school choice process for the round is closed.  We are no longer accepting choices on this system. If you would like to submit choices for the #{SCHOOL_YEAR_CONTEXT} school year, please visit a Welcome Center."
    else
      if schools = @student.choice_schools.select { |x| x.choice_rank.present? if x.choice_rank != 0 }.sort_by {|x| x.choice_rank }
        @choice_schools = schools
      elsif schools = @student.starred_schools.all
        @choice_schools = schools
      else
        @choice_schools = []
      end

      @student.choice_schools.includes(:school).order(:sort_order).all.each do |student_school|
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
      redirect_to order_choice_schools_path, alert: "Please rank three or more schools and then submit your list"
    else
      rankings = params[:schools].values.select {|x| x.present?}
      order_ranking = rankings.map {|x| x.try(:to_i)}.sort.include? (1)
      properly_formatted = rankings.map {|x| x.try(:to_i)}.sort == (rankings.map {|x| x.try(:to_i)}.sort[0]..rankings.map {|x| x.try(:to_i)}.sort[-1]).to_a rescue false
      isRankings_Integer = rankings.all? {|i|i.to_i > 0 }

      duplicate_rankings = params[:schools].values.detect{ |e| params[:schools].values.count(e) > 1 }.present?
      if duplicate_rankings
        redirect_to order_choice_schools_path, alert: "Duplicate rankings are not allowed!"
      else
        if properly_formatted && isRankings_Integer && order_ranking
          response = Webservice.get_student_homebased_choices(session[:caseid], SCHOOL_YEAR_CONTEXT, SERVICE_CLIENT_CODE)
          count = params[:schools].values.reject(&:empty?).count
          params[:schools].each do |id, rank|
            if rank.present?
              school = StudentSchool.find(id)
              if response.select{|key| key[:SchoolEligibility].include? "Student Sch"}.present?
                response.select{|key| key[:SchoolEligibility].include? "Student Sch"}.each do |value|
                  if value[:SchoolLocalId].present? && value[:SchoolLocalId] == id || params[:schools].values.reject(&:empty?).count >= 3
                    school.update_column(:choice_rank, rank)
                    count = count - 1
                    redirect_to summary_choice_schools_path and return if count == 0
                  else
                    school.update_column(:choice_rank, rank)
                    redirect_to order_choice_schools_path, alert: "Because you haven't selected your students current school please rank 3 schools" and return
                  end
                end
              else
                if params[:schools].values.reject(&:empty?).count >= 3
                  school.update_column(:choice_rank, rank)
                  count = count - 1
                  redirect_to summary_choice_schools_path and return if count == 0
                else
                  school.update_column(:choice_rank, rank)
                  redirect_to order_choice_schools_path, alert: "Because you haven't selected your students current school please rank 3 schools" and return
                end
              end
            end
          end
        else
          redirect_to order_choice_schools_path, alert: "Please ensure that your rankings are numbers in order and start with '1'"
        end
      end
    end
  end

  # GET
  def summary
    if Webservice.get_student(@student.token, session[:caseid]).try(:[], :HasRankedChoiceSubmitted) == true
      redirect_to success_choice_schools_path, alert: "You have already submitted your school choice list for the current school year. Your choice list is as follows:"
    else
      @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? if x.choice_rank != 0 }.sort_by {|x| x.choice_rank }
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
        payload << { "ProgramCode" => student_school.program_code, "SchoolLocalId" => student_school.school.bps_id, "Rank" => student_school.choice_rank, "Grade" => @student.formatted_grade_level}
      end
      
      @student.update_attributes(ranked: true, ranked_at: Time.now, parent_name: params[:parent_name])
      rankedResponse = Webservice.save_ranked_choices(session[:session_token], payload, params[:parent_name], SERVICE_CLIENT_CODE, SCHOOL_YEAR_CONTEXT, session[:caseid])
      Webservice.send_ranked_email(session[:session_token], @student.token, session[:caseid])
      redirect_to success_choice_schools_path
    end
  end

  # GET
  def success
    Rails.logger.info "****student token #{@student.token}"
    if @student.token.present?
      @choice_schools = Webservice.get_ranked_choices(@student.token, session[:caseid])
    else
      @choice_schools = []
    end
    Rails.logger.info "*********************** success page schools = #{@choice_schools}"
    # @choice_schools = @student.choice_schools.select { |x| x.choice_rank.present? }.sort_by {|x| x.choice_rank }
  end

  private

  def redirect_if_student_token_invalid
    if params[:token].blank? || Webservice.get_student(params[:token], params[:caseid]).try(:[], :Token) != params[:token] || params[:caseid].blank?
      redirect_to choice_schools_path(token: params[:token], caseid: session[:caseid]), alert: "Please access this site from a valid URL found in your invitation email."
    end
  end

  def redirect_if_session_token_invalid
    # finding a student with the session token only tells us whether one has been
    # created in the past. we also need to verify that the token isn't expired
    if session[:session_token].blank? || @student.blank? 
      redirect_to verify_choice_schools_path(token: @student.try(:token), caseid: session[:caseid]), alert: "Please access this site from a valid URL found in your invitation email."
    elsif Webservice.validate_session_token(session[:session_token]).try(:[], :messageContent) != "Session token is valid"
      redirect_to verify_choice_schools_path(token: @student.try(:token), caseid: session[:caseid]), alert: "Your session token has expired. Please revalidate your account."
    end
  end

  def find_student_by_session_token
    # see if we can find a student with this token, which should have been
    # saved on the authenticate method. if not, go back and get one
    @student = Student.where(session_token: session[:session_token]).first
  end
end
