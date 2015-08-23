class Users::ConfirmationsController < Devise::ConfirmationsController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }, on: :create
  
  # GET /resource/confirmation/new
  def new
    super
  end

  # POST /resource/confirmation
  # API FORMAT
  # {
  #   @"user": { @"email": "xxx@example.com" }, 
  #   @"commit": @"Resend confirmation instructions"
  # }
  def create
    if request.format == "text/html"
      super
    else
      self.resource = resource_class.send_confirmation_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        respond_to do |format|
          format.json {render json: {message: "Confirmation Sent!"}}
        end
      else
        respond_to do |format|
          format.json {render json: {user: resource, message: resource.errors}}
        end
      end
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    super
  end

  protected

  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(resource_name)
    super(resource_name)
  end

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    super(resource_name, resource)
  end
end
