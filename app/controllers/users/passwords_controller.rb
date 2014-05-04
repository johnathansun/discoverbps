class Users::PasswordsController < Devise::PasswordsController
	layout 'application'

	prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit

	def create
		self.resource = User.send_reset_password_instructions(resource_params)
		yield resource if block_given?

		if successfully_sent?(self.resource)
			return render :json => {:success => true}
		else
			return render :json => {:success => false, :errors => ["Sorry, we couldn't find that email address."]}
		end
	end

	# PUT /resource/password
	def update
		# self.resource = resource_class.reset_password_by_token(resource_params)
		resource = User.where(reset_password_token: resource_params[:reset_password_token]).first

		if resource.present?
			if resource.persisted?
				if resource.reset_password_period_valid?
					resource.reset_password!(resource_params[:password], resource_params[:password_confirmation])
				else
					resource.errors.add(:reset_password_token, :expired)
				end
			end

			yield resource if block_given?

			if resource.errors.empty?
				resource.unlock_access! if unlockable?(resource)
				flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
				set_flash_message(:notice, flash_message) if is_flashing_format?
				sign_in(resource_name, resource)
				respond_with resource, :location => after_resetting_password_path_for(resource)
			else
				respond_with resource
			end
		else
			redirect_to new_user_password_path, alert: "We couldn't validate your email token. Please try again."
		end
	end
end
