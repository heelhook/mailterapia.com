#= require 'pen'
#= require markdown

$ ->
  setTimeout ->
    window.editor = new Pen('#message_body')
  , 250

  $('form#new_message,form.edit_message').on 'submit', (e) ->
    html = $('#message_body').html()
    window.editor.destroy()
    $('#message_body_real').val(html)

  $('input#reply').on 'click', (e) ->
    $(@).slideUp =>
      $('.message-container').slideDown()
    false

  $('input#send').on 'click', (e) ->
    $('input#message_status').val('unread')

  $('#save-draft').on 'click', (e) ->
    $('input#message_status').val('draft')
    # message = message:
    #   subject: $('input#message_subject').val()
    #   to_id: $('input#message_to_id').val()
    #   body: $('#message_body').html()
    #   in_reply_to_id: $('input#message_in_reply_to_id').val()
    #   status: 'draft'

    # id = $('input#message_draft_id').val()
    # if id?
    #   url = "/mensajes/#{id}"
    #   method = 'put'
    # else
    #   url = "/mensajes"
    #   method = 'post'

    # $.ajax
    #   url: url
    #   method: method
    #   data: message
    #   success: (e) ->
    #     alert 'Tu mensaje fue guardado!'

    # false
