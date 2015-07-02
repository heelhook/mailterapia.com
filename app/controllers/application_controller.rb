class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :load_coupon

  # before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    if @coupon
      "/clientes/#{@coupon.id}"
    else
      request.env['omniauth.origin'] || stored_location_for(resource) || root_path
    end
  end

  def load_coupon
    if session[:coupon]
      begin
        @coupon = Stripe::Coupon.retrieve(session[:coupon])
      rescue Stripe::InvalidRequestError => e
        session[:coupon] = nil
      end
    end
  end
end
