class TransactionMailer < MandrillMailer::TemplateMailer
  default from_name: 'Marina Diaz'

  def welcome(user, password)
    @subject = "Bienvenido a tu Mailterapia"
    mandrill_mail(
      template: 'welcome',
      reply_to: user.service_email,
      subject: @subject,
      from: user.service_email,
      to: {
        email: user.email,
        name: user.nombre_completo
      },
      vars: {
        'NAME' => user.nombre_completo,
        'EMAIL' => user.email,
        'SUBJECT' => @subject,
        'PASSWORD' => password,
        'SERVICE_EMAIL' => user.service_email,
      },
      important: true,
      inline_css: true,
      async: true,
    )
  end

  def notification_new_user(user)
    @subject = "Nuevo registro en Mailterapia"
    mandrill_mail(
      template: 'notification-registration',
      from: user.service_email,
      reply_to: user.email,
      subject: @subject,
      to: {
        email: "marinadiazc@gmail.com",
        name: "Marina Diaz"
      },
      vars: {
        'NAME' => user.nombre_completo,
        'EMAIL' => user.email,
        'SLUG' => user.slug,
        'CONSULTATION_TYPE' => user.consultation_type.try(:name),
        'CONSULTATION_DESCRIPTION' => user.consultation_description,
        'SUBJECT' => @subject,
        'SERVICE_EMAIL' => user.service_email,
      },
      important: true,
      inline_css: true,
      async: true,
    )
  end

  def notification_payment(user, amount, service)
    @subject = "Hemos recibido tu pago correctamente"
    mandrill_mail(
      template: 'notification-payment',
      from: user.service_email,
      reply_to: user.service_email,
      subject: @subject,
      from: user.service_email,
      bcc: 'marinadiazc@gmail.com',
      to: {
        email: user.email,
        name: user.nombre_completo,
      },
      vars: {
        'NAME' => user.nombre_completo,
        'SERVICE' => service,
        'AMOUNT' => amount,
        'SUBJECT' => @subject,
        'SERVICE_EMAIL' => user.service_email,
      },
      important: true,
      inline_css: true,
      async: true,
    )
  end

  def new_message_notification(message)
    mandrill_mail(
      template: "notification-message",
      from: message.from.email,
      to: {
        email: message.to.email,
        name: message.to.nombre_completo,
      },
      vars: {
        'NAME' => message.to.nombre,
        'SUBJECT' => message.subject,
        'LINK_MESSAGE' => "https://www.mailterapia.com/clientes/mensajes/#{message.id}",
      },
      important: true,
      inline_css: true,
      async: true,
    )
  end

  def consentimiento_informado(user, nombre, id)
    mandrill_mail(
      template: "consentimiento-informado",
      from: user.email,
      to: {
        email: "marinadiazc@gmail.com",
        name: "Marina Diaz",
      },
      vars: {
        'EMAIL' => user.email,
        'NOMBRE_EN_FORMULARIO' => nombre,
        'ID' => id,
        'FECHA' => Date.today.strftime('%d/%m/%Y'),
      },
      important: true,
      inline_css: true,
      async: true,
    )
  end
end
