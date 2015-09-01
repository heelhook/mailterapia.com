class PaymentsController < ApplicationController
  before_filter :load_stripe_customer_exists, only: [:new, :descuentosorteo]

  def new
  end

  def descuentosorteo
    redirect_to action: :new unless @coupon.try(:id) == 'descuentosorteo'
  end

  def create
    customer = current_user.stripe_customer
    session[:first_payment] = true unless customer

    customer ||= Stripe::Customer.create(
      description: current_user.nombre_completo,
      email: params[:stripe_token][:email],
    )

    customer.sources.create(source: params[:stripe_token][:id])

    current_user.update_attributes!(stripe_token: customer.id)

    wordbank_balance = 0
    type = :charge

    case params[:plan]
    when 'consulta-expres'
      amount = 4500
      service = 'consulta-expres'
      service_name = 'Consulta expres'
      comienzo_terapia_template_name = 'consulta-expres'
    when 'wordbank-25'
      wordbank_balance = 500
      amount = 2500
      service_name = 'Bono WordBank 500 palabras'
      comienzo_terapia_template_name = 'wordbank'
    when 'wordbank-45'
      wordbank_balance = 1000
      amount = 4500
      service_name = 'Bono WordBank 1000 palabras'
      comienzo_terapia_template_name = 'wordbank'
    when 'wordbank-60'
      wordbank_balance = 1500
      amount = 6000
      service_name = 'Bono WordBank 1500 palabras'
      comienzo_terapia_template_name = 'wordbank'
    when 'wordbank-75'
      wordbank_balance = 2000
      amount = 7500
      service_name = 'Bono WordBank 2000 palabras'
      comienzo_terapia_template_name = 'wordbank'
    when 'suscripcion-ilimitada'
      type = :subscription
      plan = 'suscripcion-ilimitada'
      service_name = 'Suscripción Ilimitada'
      comienzo_terapia_template_name = 'ilimitada'
      amount = 7500
    end

    case session[:coupon]
    when 'descuentosorteo'
      if service == 'consulta-expres'
        amount = 3375
        session[:coupon] = nil
      end
    end

    case type
    when :charge
      charge = Stripe::Charge.create(
        amount: amount,
        currency: 'EUR',
        customer: customer.id,
        description: params[:plan],
        statement_descriptor: 'Mailterapia.com',
      )

      if wordbank_balance > 0
        current_user.wordbank_items.create!(
          word_count: wordbank_balance,
          memo: charge.id,
        )
      end

      if service
        current_user.update_attributes!(
          active_service: service,
        )
      end
    when :subscription
      customer.subscriptions.create(
        plan: plan,
      )

      current_user.update_attributes!(
        active_subscription: plan,
      )
    end

    TransactionMailer.notification_payment(current_user, amount/100.0, service_name).deliver

    flash[:notice] = '¡El pago se  ha realizado con éxito! Comienza a trabajar con tu terapeuta'

    head :ok
  end

  def destroy
    customer = current_user.stripe_customer
    customer.subscriptions.first.delete

    current_user.update_attributes!(
      active_subscription: nil,
    )

    flash[:notice] = 'Tu suscripción ha sido cancelada.'

    head :ok
  end

  private

  def load_stripe_customer_exists
    @stripe_customer = current_user.chargable_stripe_customer?
  end
end
