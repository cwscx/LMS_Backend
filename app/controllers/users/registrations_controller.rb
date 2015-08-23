class Users::RegistrationsController < Devise::RegistrationsController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }, on: :create
 
  before_filter :configure_sign_up_params, only: [:create]
  before_filter :configure_account_update_params, only: [:update]


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
      user = User.new(request.params[:user])    
      save_user(user)
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
    puts self.resource = resource_class.to_adapter
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
          format.json {render json: {user: resource, message: "Password Updated"}, status: :accepted}
        end
      else
        clean_up_passwords resource
        respond_to do |format|
          format.json {render json: {user: resource, message: "Password Update Failure"}, status: :no_content}
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

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :username << :phone_number
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.for(:account_update) << :phone_number
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  
  private
  
  def save_user(user)
    # When we try to save the user, if it's the mobile phone (self defined attribute) duplication,
    # An exception will be raised. However if it's email which is carried by default, only an error
    # message, but no Excpetion.
    begin 
      user.save
      respond_to do |format|
        if user.persisted?
          # !!! How to handle email verification for iOS
          # if user.user.active_for_authentication?   will return false for verification
          format.json { render json:
            {
              user: user,
              reason: ""
            },
            status: 200
          }
        else
          format.json { render json:
            {
              error: user.errors,
              reason: "Email Existed"
            },
            status: 202
          }
        end
      end
    rescue Exception => e
      # If the Exception is the duplication of mobile_phone
      if e.class == ActiveRecord::RecordNotUnique
        respond_to do |format|
          format.json { render json:
            {
              error: {:mobile_phone => ["has already been taken"]},
              reason: "Mobile Phone Existed"
            },
            status: 202
          }
        end
      else
        respond_to do |format|
          format.json {render json:
            {
              error: e.message,
              reason: "Unknown Error"
            },
            status: 400
          }
        end
      end
    end
  end
end
