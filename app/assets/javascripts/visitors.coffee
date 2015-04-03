$ ->
  $('#welcome-box-continue').on 'click', (e) ->
    $('#welcome').slideUp -> $('#content').slideDown()
    false

  if $('#welcome').length is 0
    $('#content').show()
