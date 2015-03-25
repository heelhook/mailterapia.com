$ ->
  stripe_api_public = $('#stripe_key').val()

  if stripe_api_public?
    $handler = StripeCheckout.configure
      key: stripe_api_public
      image: "https://stripe.com/img/documentation/checkout/marketplace.png"
      name: "MailTerapia"
      description: "Enter your details to continue"
      email: $('#email').val()
      currency: 'EUR'
      allowRememberMe: false
      token: (token) ->
        $.ajax
          url: '/payments'
          method: 'post'
          data:
            plan: $('input#plan').val()
            stripe_token: token
          complete: -> payment_completed()

    $('.cancel_plan').on 'click', (e) ->
      if confirm('Seguro que quieres cancelar?')
        $.ajax
          url: '/payments/suscripcion-ilimitada'
          method: 'delete'
          complete: -> payment_completed()

      false

    $('.choose_plan').on 'click', (e) ->
      stripe_customer = $('#stripe_customer').val() is 'true'
      plan_name = $(e.target).data().name

      $('input#plan').val(plan_name)

      if stripe_customer
        $.ajax
          url: '/payments'
          method: 'post'
          data:
            plan: $('input#plan').val()
          complete: -> payment_completed()
      else
        $handler.open(
          switch plan_name
            when 'consulta-360'
              description: 'Consulta 360'
              panelLabel: 'Abonar Consulta'
            when 'wordbank-20'
              description: 'Bono 20 €'
              panelLabel: 'Cargar WordBank'
            when 'wordbank-35'
              description: 'Bono 35 €'
              panelLabel: 'Cargar WordBank'
            when 'wordbank-60'
              description: 'Bono 60 €'
              panelLabel: 'Cargar WordBank'
            when 'suscripcion-ilimitada'
              description: 'Suscripcion Ilimitada'
              panelLabel: 'Activar Suscripcion'
        )

      false

  payment_completed = ->
    $(location).attr('href', '/')

