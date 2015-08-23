#= require tinymce-jquery

setup_message = ->
  setTimeout ->
    $('textarea.tinymce').tinymce
      menubar: false
      toolbar: ["blockquote | bold italic underline strikethrough | undo redo | fontsizeselect | bullist numlist outdent indent  | cut copy paste | image | link | emoticons"]
      plugins: "image,link,emoticons"
      skin: "pepper-grinder"
      language_url: "/assets/es.js"
      height: 500
  , 1000

  $('body').on 'click', '.delete-mail', (e) ->
    if ! confirm("¿Seguro que deseas borrar este mensaje? No podrás recuperarlo luego.")
      return false

  $('body').on 'ajax:beforeSend', 'form#new_message,form.edit_message', (e) ->
    $draft_interval = true
    if $('input#message_status').val() is 'draft'
      $('input#save-draft').val('Guardando...')
      $('input#save-draft').prop('disabled', true)
    else
      $('input#send').val('Enviando...')
      $('input#send').prop('disabled', true)

  $('body').on 'ajax:success', 'form#new_message,form.edit_message,form.replyform', (e, data) ->
    $draft_paused = false
    if $('input#message_status').val() is 'draft'
      $('form#new_message input#message_id,form#edit_message input#message_id').val(data.id)
      $('form#new_message,form#edit_message').attr('action', data.action)
      $('form#new_message,form#edit_message').attr('id', 'edit_message')
      $('form#new_message,form#edit_message').attr('class', 'edit_message')
      $('form#new_message,form#edit_message').attr('method', 'put')
      $('input#save-draft').val('Guardado!')
      setTimeout ->
        $('input#save-draft').val('Guardar Borrador')
        $('input#save-draft').prop('disabled', false)
      , 1000
    else
      $(location).attr('href', '/clientes/mensajes')
      $('input#send').val('Enviado!')

  $('body').on 'ajax:error', 'form#new_message,form.edit_message', (e, data, status, xhr) ->
    alert "El mensaje no fue enviado correctamente. Asegurate de que tu conexión funciona correctamente y vuelve a intentarlo. Si el problema continua escribenos a soporte@mailterapia.com. #{data.statusText}."
    $('input#send').val('Enviar')
    $('input#send').prop('disabled', false)
    $draft_paused = false

  $('input#reply').on 'click', (e) ->
    $(@).slideUp =>
      $('.replyform').slideDown()
    false

  $('input#send').on 'click', (e) ->
    $draft_paused = true
    $('input#message_status').val('unread')

  $('#save-draft').on 'click', (e) ->
    $('input#message_status').val('draft')

  $('input#message_tag_list').on 'keydown', (e) ->
    $('.tags input[type="submit"]').fadeIn()

  $('.tags form').on 'ajax:success', ->
    $('.tags input[type="submit"]').fadeOut()
    $('.replyform input#message_tag_list').val($('input#message_tag_list[type="text"]:first').val())

  $('input#send,input#save-draft').on 'click', ->
    $draft_paused = true
    $('input#message_body').val(tinyMCE.activeEditor.getContent())

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

  setInterval ->
    $('#save-draft').click() unless $draft_paused? && $draft_paused
  , 30000

  if $('.replyform[id^="edit_message_"]').length == 1
    $('input#reply').slideUp ->
      $('.replyform').slideDown()

$(document).on 'page:load ready', -> setup_message()
