$(window).ready ->
# $("body").on "click", ".bar-menu", (e) ->
#   e.stopImmediatePropagation()

  $(document).on 'click', "._card-link", ->
    cl = $(this)
    if cl.data("skip") == "on"
      cl.data "skip", null
    else if cl.closest("._card-link-modal")[0]
      cl.find("._modal-page-link").trigger "click"
    else
      window.location = decko.path cl.data("cardLinkName")

   $('body').on 'click', "._card-link a, ._card-link ._card-link-clickable", (event)->
     a = $(this)
     if a.hasClass("_over-card-link") || a.closest("._over-card-link")[0]
       # skip card link action
       a.closest("._card-link").data "skip", "on"
     else
       # don't follow original link
       event.preventDefault()
