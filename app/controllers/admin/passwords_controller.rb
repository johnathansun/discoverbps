class Admin::PasswordsController < Devise::PasswordsController
	before_filter :authenticate_admin!
	layout 'admin'
end
