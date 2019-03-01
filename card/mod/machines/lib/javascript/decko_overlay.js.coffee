jQuery.fn.extend
  overlaySlot: ->
    close = @closest(".card-slot._overlay")
    close[0] && close || $(@closest(".overlay-container").find("._overlay")[0])

  addOverlay: (overlay, $slotter) ->
    if @parent().hasClass("overlay-container")
      if $(overlay).hasClass("_stack-overlay")
        @before overlay
      else
        $("._overlay-origin").removeClass("_overlay-origin")
        @replaceOverlay(overlay)

    else
      @find(".tinymce-textarea").each ->
        tinyMCE.execCommand('mceRemoveControl', false, $(this).attr("id"))
      @wrapAll('<div class="overlay-container">')
      @addClass("_bottomlay-slot")
      @before overlay

    $slotter.markOrigin("overlay")

  replaceOverlay: (overlay) ->
    @overlaySlot().replaceWith overlay
    $(".bridge-sidebar .tab-pane:not(.active) .bridge-pills > .nav-item > .nav-link.active").removeClass("active")

  removeOverlay: () ->
      @overlaySlot().removeOverlaySlot()

  removeOverlaySlot: () ->
    if @siblings().length == 1
      bottomlay = $(@siblings()[0])
      if bottomlay.hasClass("_bottomlay-slot")
        bottomlay.unwrap().removeClass("_bottomlay-slot").updateBridge(true, bottomlay)
        bottomlay.find(".tinymce-textarea").each ->
          decko.initTinyMCE($(this).attr("id"))

    @remove()

