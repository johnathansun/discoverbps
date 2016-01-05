class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :enforce_https
  before_filter :set_current_student_from_params
  helper_method :zone_school_grades
  helper_method :current_student
  helper_method :current_user_students

  private

  def enforce_https
    unless request.ssl?
      if request.domain == 'bostonpublicschools.org' && request.subdomain == 'discover'
        redirect_to protocol: "https://"
      end
    end
    return true
  end

  # if a student_id is in the params, set session[:current_student_id] to match
  def set_current_student_from_params
    if params[:student_id].present?
      if current_user.present? && current_user.students.find(params[:student_id]).present?
        session[:current_student_id] = current_user.students.find(params[:student_id]).id
      elsif Student.where(id: params[:student_id], session_id: session[:session_id]).first.present?
        session[:current_student_id] = Student.where(id: params[:student_id], session_id: session[:session_id]).first.id
      end
    end
  end

  def zone_school_grades
  	if Date.today > Date.parse('01-11-2017')
  		[]
  	elsif Date.today > Date.parse('01-11-2016')
  		['5']
		elsif Date.today > Date.parse('01-11-2015')
  		['4', '5']
  	elsif Date.today > Date.parse('01-11-2014')
  		['3', '4', '5']
  	elsif Date.today > Date.parse('01-11-2013')
  		['2', '3', '4', '5', '8']
  	end
  end

  def current_student
  	if session[:current_student_id].present?
	  	Student.find(session[:current_student_id]) rescue nil
    elsif current_user_students.try(:first).present?
      session[:current_student_id] = current_user_students.first.id
      Student.find(session[:current_student_id]) rescue nil
    else
      nil
	  end
  end

  def current_user_students
  	if current_user && current_user.students.present?
      current_user.students.verified
    elsif session[:session_id].present?
      Student.verified.where(session_id: session[:session_id]).order(:first_name)
    else
      []
    end
  end

	# def store_location
	#  # store last url - this is needed for post-login redirect to whatever the user last visited.
	#     if (request.fullpath != "/users/sign_in" && \
	#         request.fullpath != "/users/sign_up" && \
	#         request.fullpath != "/users/password" && \
	#         !request.xhr?) # don't store ajax calls
	#       session[:previous_url] = request.fullpath
	#     end
	# end

	def after_sign_out_path_for(resource_or_scope)
	  root_url
	end

	def after_sign_up_path_for(resource)
	  root_path
	end

  def after_sign_in_path_for(resource)
		if resource.present? && resource.class.to_s == 'User'
			root_url
		elsif resource.present? && resource.class.to_s == 'Admin'
			admin_root_url
		else
			root_url
		end
	end
end
