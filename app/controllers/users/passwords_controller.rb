class Users::PasswordsController < Devise::PasswordsController
	layout 'application'

	prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit

	def create
		self.resource = User.send_reset_password_instructions(resource_params)
		yield resource if block_given?

		if successfully_sent?(self.resource)
			if request.xhr?
				render :json => {:success => true}
			else
				render action: "new", :notice => "We sent a confirmation email to #{resource.email}. Please check your email for instructions on resetting your password."
			end
		else
			if request.xhr?
				render :json => {:success => false, :errors => ["Sorry, we couldn't find a user with that email address. Please try again or create a new account if you haven't done so already."] }
			else
				render action: "new", :alert => "Sorry, we couldn't find a user with that email address. Please try again or create a new account if you haven't done so already."
			end
		end
	end

end
