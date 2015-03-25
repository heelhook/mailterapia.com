class VisitorsController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_title = "Bienvenido"
    @page_subtitle = "Registrate ahora"

    redirect_to new_payment_path unless current_user.access_to_service?
  end
end
