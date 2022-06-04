jQuery.fn.extend
  overlaySlot: ->
    oslot = @closest(".card-slot._overlay")
    return oslot if oslot[0]?
    oslot = @closest(".overlay-container").find("._overlay")
    oslot[0]? && $(oslot[0])

  addOverlay: (overlay, $slotter) ->
    if @parent().hasClass("overlay-container")
      if $(overlay).hasClass("_stack-overlay")
        @before overlay
      else
        $("._overlay-origin").removeClass("_overlay-origin")
        @replaceOverlay(overlay)
    else
      if @parent().hasClass("_overlay-container-placeholder")
        @parent().addClass("overlay-container")
      else
        @wrapAll('<div class="overlay-container">')
      @addClass("_bottomlay-slot")
      @before overlay

    $slotter.registerAsOrigin("overlay", overlay)
    decko.contentLoaded(overlay, $slotter)

  replaceOverlay: (overlay) ->
    @overlaySlot().trigger "slot:destroy"
    @overlaySlot().replaceWith overlay
    $(".bridge-sidebar .tab-pane:not(.active) .bridge-pills > .nav-item > .nav-link.active").removeClass("active")

  isInOverlay: ->
    return @closest(".card-slot._overlay").length

  removeOverlay: () ->
      slot = @overlaySlot()
      if slot
        slot.removeOverlaySlot()

  removeOverlaySlot: () ->
    @trigger "slot:destroy"
    if @siblings().length == 1
      bottomlay = $(@siblings()[0])
      if bottomlay.hasClass("_bottomlay-slot")
        if bottomlay.parent().hasClass("_overlay-container-placeholder")
          bottomlay.parent().removeClass("overlay-container")
        else
          bottomlay.unwrap()
        bottomlay.removeClass("_bottomlay-slot").updateBridge(true, bottomlay)

        #bottomlay.find(".tinymce-textarea").each ->
        #  tinymce.EditorManager.execCommand('mceAddControl',true, editor_id);
        #  decko.initTinyMCE($(this).attr("id"))

    @remove()
