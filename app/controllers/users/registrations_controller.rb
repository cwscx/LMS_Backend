class Users::RegistrationsController < Devise::RegistrationsController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }, on: :create
 
  before_filter :configure_sign_up_params, only: [:create]
  #before_filter :configure_account_update_params, only: [:update]


  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    # If the request comes from html, use devise's default create method
    if request.format == "text/html"
      super
    # If the request doesn't come from html, it comes from json
    else
      # Check the uniqness of phone_number
      if !(User.find_by(phone_number: sign_up_params[:phone_number]).nil?)
        respond_to do |format|
          format.json {render json: {status: "Phone Number Existed"}, status: 202}
        end
      else
        build_resource(sign_up_params)
    
        resource.save    
        yield resource if block_given?
    
        # Check if the email is signed up before
        if resource.persisted?      
          # Check if this account is already confirmed. In this case, only the second condition will be called.
          if resource.active_for_authentication?
            sign_up(resource_name, resource)
        
            respond_to do |format|
              format.json {render json: {user: resource, status: "Created"}, status: 201}
            end
          else 
            expire_data_after_sign_in!
        
            respond_to do |format|
              format.json {render json: {user: resource, status: "Created"}, status: 201}
            end
          end
        else
          clean_up_passwords resource
          set_minimum_password_length
          respond_to do |format|
            format.json {render json: {status: "Existed"}, status: 202}
          end
        end
      end
    end
  end


  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  # For the API, the caller must use this method to update the user's password in side the success login block
  # API FORMAT
  # {
  #   @"user": { 
  #     @"email": "xxx@example.com",
  #     @"password": @_new_password_
  #     @"password_confirmation": @_new_password_confirmation_
  #     @"current_password": @_old_password_
  #   }
  # }
  def update
    if request.format == "text/html"
      super
    else
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?

      if resource_updated
        sign_in resource_name, resource, bypass: true
        respond_to do |format|
          format.json {render json: {user: resource, status: "Password Updated"}, status: :accepted}
        end
      else
        clean_up_passwords resource
        respond_to do |format|
          format.json {render json: {status: "Password Update Failure"}, status: 202}
        end
      end
    end
  end
  

  # DELETE /resource
  def destroy
    super
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :username << :phone_number
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update)
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end
end
