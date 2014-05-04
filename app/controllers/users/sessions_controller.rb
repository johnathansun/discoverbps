class Users::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, only: [ :new, :create ]
  prepend_before_filter :allow_params_authentication!, only: :create
  prepend_before_filter :verify_signed_out_user, only: :destroy
  prepend_before_filter only: [ :create, :destroy ] { request.env["devise.skip_timeout"] = true }
	
  # GET /resource/sign_in
  def new
    self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

 #  # POST /resource/sign_in
	# def create
 #    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
 #    sign_in_and_redirect(resource_name, resource)
 #  end
 
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    if request.xhr?
      render :json => {:success => true}
    else
      redirect_to schools_path
    end
  end
 
  def failure
    logger.info "*************************** login failure"
    if request.xhr?
      render :json => {:success => false, :errors => ["Login failed."]}
    else
      render action: 'new'
    end

  end

end
