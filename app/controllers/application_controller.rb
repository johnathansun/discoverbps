class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_zone_grades
  helper_method :current_student
  helper_method :current_user_students
  helper_method :student_preference_categories
  # after_filter :store_location

  private

  def set_zone_grades
  	if Date.today > Date.parse('01-11-2017')
  		@zone_grades = []
  	elsif Date.today > Date.parse('01-11-2016')
  		@zone_grades = ['5']
		elsif Date.today > Date.parse('01-11-2015')
  		@zone_grades = ['4', '5']
  	elsif Date.today > Date.parse('01-11-2014')
  		@zone_grades = ['3', '4', '5']
  	elsif Date.today > Date.parse('01-11-2013')
  		@zone_grades = ['2', '3', '4', '5', '8']
  	end
  end
  
  def current_student
  	if session[:current_student_id].present?
	  	Student.find(session[:current_student_id]) rescue nil
	  end
  end

  def current_user_students
  	if current_user && current_user.students.present?
      return current_user.students.verified
    elsif session[:session_id].present?
      return Student.verified.where(session_id: session[:session_id]).order(:first_name)
    else
      return []
    end
  end

  def student_preference_categories
  	PreferenceCategory.preference_panel.grade_level_categories(current_student.try(:grade_level))
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
