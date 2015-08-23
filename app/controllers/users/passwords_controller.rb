class Users::PasswordsController < Devise::PasswordsController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }, on: :create
  
  # GET /resource/password/new
  def new
    super
  end

  # POST /resource/password
  # API FORMAT
  # {
  #   @"user": { @"email": "xxx@example.com" }, 
  #   @"commit": @"Send me reset password instructions"
  # }
  def create
    puts request.params
    if request.format == 'text/html'
      super
    else
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        respond_to do |format|
          format.json {render json: {message: "Email Sent Successfully"}}
        end
      else
        respond_to do |format|
          format.json {render json: {user: resource, message: resource.errors}}
        end
      end
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update
    super
  end

  # protected

  def after_resetting_password_path_for(resource)
    super(resource)
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    super(resource_name)
  end
end
