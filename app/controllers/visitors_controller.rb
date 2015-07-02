class VisitorsController < ApplicationController
  before_action :authenticate_user!, except: [:coupon]

  def index
    unless current_user.access_to_communication?
      if session[:coupon]
        redirect_to "/clientes/#{session[:coupon]}"
      else
        redirect_to new_payment_path
      end
    end

    if session[:first_payment]
      @first_payment_alert = true
      session[:first_payment] = nil
    end
  end

  def coupon
    coupon = Stripe::Coupon.retrieve(params[:code])
    session[:coupon] = params[:code]
    redirect_to "https://www.mailterapia.com/#{session[:coupon]}"
  rescue Stripe::InvalidRequestError => e
  end

  def consentimiento
    if !params[:nombre_completo].blank? && !params[:id].blank?
      TransactionMailer.consentimiento_informado(current_user, params[:nombre_completo], params[:id]).deliver
      current_user.update_attributes(agreed_consentimiento_informado: true)
      redirect_to action: :informacion_comienzo
    end
  end

  def informacion_comienzo
    @service = case current_user.service
    when 'consulta-expres' then 'consulta-expres'
    when 'suscripcion-ilimitada' then 'suscripcion-ilimitada'
    when 'wordbank' then 'suscripcion-ilimitada'
    else
      redirect_to action: :index
    end
  end
end
