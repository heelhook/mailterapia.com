#= require 'pen'
#= require markdown

setup_message = ->
  setTimeout ->
    window.editor = new Pen('#message_body')
  , 250

  $('body').on 'click', '.delete-mail', (e) ->
    if ! confirm("¿Seguro que deseas borrar este mensaje? No podrás recuperarlo luego.")
      return false

  $('form#new_message,form.edit_message').on 'ajax:beforeSend', (e) ->
    $('input#send').val('Enviando...')
    $('input#send').prop('disabled', true)

  $('form#new_message,form.edit_message').on 'ajax:complete', (e) ->

  $('form#new_message,form.edit_message').on 'ajax:success', (e) ->
    $(location).attr('href', '/clientes/mensajes')
    $('input#send').val('Enviado!')

  $('form#new_message,form.edit_message').on 'ajax:error', (e, data, status, xhr) ->
    alert "El mensaje no fue enviado correctamente. Asegurate de que tu conexión funciona correctamente y vuelve a intentarlo. Si el problema continua escribenos a soporte@mailterapia.com. #{data.statusText}."
    $('input#send').val('Enviar')
    $('input#send').prop('disabled', false)

  $('input#reply').on 'click', (e) ->
    $(@).slideUp =>
      $('.message-body-editor').slideDown()
    false

  $('input#send').on 'click', (e) ->
    $('input#message_status').val('unread')
    html = $('#message_body').html()
    window.editor.destroy()
    $('#message_body_real').val(html)

  $('#save-draft').on 'click', (e) ->
    $('input#message_status').val('draft')

  $('[data-role="new-folder"]').on 'click', (e) ->
    name = prompt "Nombre de la nueva carpeta:"
    if name?
      $.ajax
        url: $(@).attr('href')
        method: 'post'
        data:
          folder:
            name: name
        complete: ->
          location.reload()
    false

  $('select[name="move_to_folder"]').on 'change', (e) ->
    id = $(@).parents('.message[data-id]').data().id
    folder = $(@).val()

    $.ajax
      url: "/clientes/mensajes/#{id}"
      method: 'put'
      data:
        message:
          folder_id: folder
      beforeSend: =>
        $(".message[data-id='#{id}'] .spinner").show()
        $(".message[data-id='#{id}'] #move_to_folder").hide()
      success: ->
        $(".message[data-id='#{id}'] .spinner").hide()
        $(".message[data-id='#{id}'] #move_to_folder").show()

$(document).on 'page:load ready', -> setup_message()
