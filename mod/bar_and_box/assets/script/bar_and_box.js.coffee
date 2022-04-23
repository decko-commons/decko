$(window).ready ->
  $("body").on "click", ".bar-menu", (e) ->
    e.stopImmediatePropagation()

  $(document).on 'click', ".box, .bar", ->
    window.location = decko.path $(this).data("cardLinkName")

  $('body').on 'click', ".box a, .bar a", (event)->
    debugger
    if $(this).hasClass "over-bar"
      # don't count as bar click
      event.stopPropagation()
    else
      # don't follow original link
      event.preventDefault()
