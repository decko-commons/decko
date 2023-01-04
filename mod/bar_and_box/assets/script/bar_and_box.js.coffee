$(window).ready ->
# $("body").on "click", ".bar-menu", (e) ->
#   e.stopImmediatePropagation()

  $(document).on 'click', "._card-link", (event) ->
    cl = $(this)
    if cl.data("skip") == "on"
      cl.data "skip", null
    else if cl.closest("._card-link-modal")[0]
      cl.find("._modal-page-link").trigger "click"
    else
      url = decko.path cl.data("cardLinkName")
      if openInNewTab event
        window.open url, "_tab_" + Math.floor(Math.random() * 1000);
      else
        window.location = url

openInNewTab = (event) -> event.metaKey


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
