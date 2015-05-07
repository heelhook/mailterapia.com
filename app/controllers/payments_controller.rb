class PaymentsController < ApplicationController
  def new
    @stripe_customer = current_user.chargable_stripe_customer?
  end

  def create
    customer = current_user.stripe_customer
    session[:first_payment] = true unless customer

    customer ||= Stripe::Customer.create(
      source: params[:stripe_token][:id],
      description: current_user.nombre_completo,
      email: params[:stripe_token][:email],
    )

    current_user.update_attributes!(stripe_token: customer.id)

    wordbank_balance = 0
    type = :charge

    case params[:plan]
    when 'consulta-expres'
      amount = 12100
      service = 'consulta-expres'
      service_name = 'Consulta expres'
      comienzo_terapia_template_name = 'consulta-expres'
    when 'wordbank-20'
      wordbank_balance = 500
      amount = 2420
      service_name = 'Bono WordBank 20 EUR'
      comienzo_terapia_template_name = 'wordbank'
    when 'wordbank-35'
      wordbank_balance = 1000
      amount = 4235
      service_name = 'Bono WordBank 35 EUR'
      comienzo_terapia_template_name = 'wordbank'
    when 'wordbank-60'
      wordbank_balance = 2000
      amount = 7260
      service_name = 'Bono WordBank 60 EUR'
      comienzo_terapia_template_name = 'wordbank'
    when 'suscripcion-ilimitada'
      type = :subscription
      plan = 'suscripcion-ilimitada'
      service_name = 'Suscripción Ilimitada'
      comienzo_terapia_template_name = 'ilimitada'
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

    if session[:first_payment]
      TransactionMailer.comienzo_terapia(current_user, comienzo_terapia_template_name).deliver
    end

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
end
