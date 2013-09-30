class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_student

  private
  def current_student
  	Student.find(session[:current_student_id])
  end
end
