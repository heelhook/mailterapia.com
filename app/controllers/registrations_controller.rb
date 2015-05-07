class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  protected

  def update_resource(resource, params)
    if !params[:password].blank?
      resource.update_attributes(params)
    end

    resource.update_without_password(params)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:nombre, :apellido, :consultation_type_id, :consultation_description,
        :email, :password, :password_confirmation, :condiciones_de_servicio, :newsletter)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:nombre, :apellido,
        :email, :password, :password_confirmation)
    end
  end
end
