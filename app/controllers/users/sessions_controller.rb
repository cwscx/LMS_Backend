class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }, on: :create
  respond_to :html, :json
  
  # GET /resource/sign_in
  def new
    if request.format == "text/html"
      super
    else
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      yield resource if block_given?
      
      respond_to do |format|
        format.json {render json: {user: resource, methods: serialize_options(resource)}}
      end
    end
  end

  # POST /resource/sign_in
  def create
    if request.format == "text/html"
      super
    else
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      yield resource if block_given?
      
      respond_to do |format|
        format.json {render json: {user: resource}, status: 200}
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
