class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_student

  private
  def current_student
  	if session[:current_student_id].present?
	  	Student.find(session[:current_student_id]) rescue nil
	  end
  end
end
