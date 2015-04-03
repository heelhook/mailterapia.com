class VisitorsController < ApplicationController
  before_action :authenticate_user!

  def index
    redirect_to new_payment_path unless current_user.stripe_token

    if session[:first_payment]
      @first_payment_alert = true
      session[:first_payment] = nil
    end
  end
end
