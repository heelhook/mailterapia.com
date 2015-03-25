class PaymentsController < ApplicationController
  def new
    @stripe_customer = current_user.chargable_stripe_customer?
  end

  def create
    customer = current_user.stripe_customer
    customer ||= Stripe::Customer.create(
      source: params[:stripe_token][:id],
      description: current_user.name,
      email: params[:stripe_token][:email],
    )

    current_user.update_attributes!(stripe_token: customer.id)

    wordbank_balance = 0
    type = :charge

    case params[:plan]
    when 'consulta-360'
      amount = 12100
      service = 'consulta-360'
    when 'wordbank-20'
      wordbank_balance = 500
      amount = 2420
    when 'wordbank-35'
      wordbank_balance = 1000
      amount = 4235
    when 'wordbank-60'
      wordbank_balance = 2000
      amount = 7260
    when 'suscripcion-ilimitada'
      type = :subscription
      plan = 'suscripcion-ilimitada'
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

    flash[:notice] = 'El abono se realizó con éxito! Comenzá a trabajar con tu terapeuta!'

    head :ok
  end

  def destroy
    customer = current_user.stripe_customer
    customer.subscriptions.first.delete

    current_user.update_attributes!(
      active_subscription: nil,
    )

    flash[:notice] = 'Tu suscripción fue cancelada.'

    head :ok
  end
end
