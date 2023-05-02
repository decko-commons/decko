$(window).ready ->
# $("body").on "click", ".bar-menu", (e) ->
#   e.stopImmediatePropagation()

  $(document).on 'click', "._card-link", (event) ->
    cl = $(this)
    if cl.data("skip") == "on"
      cl.data "skip", null
    else if openInNewTab event
      window.open cardLinkPath(cl), "_tab_" + Math.floor(Math.random() * 1000)
    else if cl.closest("._card-link-modal")[0]
      cl.find("._modal-page-link").trigger "click"
    else
      window.location = cardLinkPath(cl)

openInNewTab = (event) -> event.metaKey
cardLinkPath = (cl) -> decko.path(cl.data("cardLinkUrl") || cl.data("cardLinkName"))

decko.slot.ready (slot)->
  # note: by using slot ready, we can make sure this event is triggered early
  slot.find("._card-link a, ._card-link ._card-link-clickable").on "click", (event) ->
   a = $(this)
   if a.hasClass("_over-card-link") || a.closest("._over-card-link")[0]
   # skip card link action
     a.closest("._card-link").data "skip", "on"
   else
     # don't follow original link
     event.preventDefault()
