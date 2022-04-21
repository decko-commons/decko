$(window).ready ->
  $(document).on 'click', ".box", ->
    window.location = decko.path $(this).data("cardLinkName")

  $('body').on 'click', ".box a", (event)->
    event.preventDefault()
