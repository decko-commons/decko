$(window).ready ->
  $("body").on "click", ".bar-menu", (e) ->
    e.stopImmediatePropagation()

  $(document).on 'click', ".box, .bar", ->
    window.location = decko.path $(this).data("cardLinkName")

  $('body').on 'click', ".box a, .bar a", (event)->
    event.preventDefault()
