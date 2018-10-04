$.extend decko,
  # returns full path with slot parameters
  slotPath: (path, slot)->
    xtra = {}
    main = $('#main').children('.card-slot').data 'cardName'
    xtra['main'] = main if main?
    if slot
      xtra['is_main'] = true if slot.isMain()
      slotdata = slot.data 'slot'
      decko.slotParams slotdata, xtra, 'slot' if slotdata?

    decko.path(path) + ( (if path.match /\?/ then '&' else '?') + $.param(xtra) )

  slotParams: (raw, processed, prefix)->
    $.each raw, (key, value)->
      cgiKey = prefix + '[' + snakeCase(key) + ']'
      if key == 'items'
        decko.slotParams value, processed, cgiKey
      else
        processed[cgiKey] = value

  slotReady: (func)->
    $('document').ready ->
      $('body').on 'slotReady', '.card-slot', (e, slotter) ->
        e.stopPropagation()
        if slotter?
          func.call this, $(this), $(slotter)
        else
          func.call this, $(this)

jQuery.fn.extend {
  slot: (status="success", mode="normal") ->
    if mode == "modal"
      modalSlot()
    else
      @selectSlot("slot-#{status}-selector") ||
        @selectSlot("slot-selector") ||
        @closest(".card-slot")

  selectSlot: (selectorName) ->
    if selector = @data(selectorName)
      slot = @findSlot selector
      slot[0] && slot

  isSlot: ->
    $(this).hasClass "card-slot"

  isMain: -> @slot().parent('#main')[0]

  findSlot: (selector) ->
    target_slot = @closest(selector)
    parent_slot = @closest '.card-slot'

    # if slot-selector doesn't apply to a child, search in all parent slots and finally in the body
    while target_slot.length == 0 and parent_slot.length > 0
      target_slot = $(parent_slot).find(selector)
      parent_slot = $(parent_slot).parent().closest '.card-slot'
    if target_slot.length == 0
      $(selector)
    else
      target_slot

  updateSlot: (url) ->
    $slot = $(this)
    $slot = $slot.slot() unless $slot.isSlot
    unless url?
      path = '~' + $slot.data('cardId') + "?view=" + $slot.data("slot")["view"]
      url = decko.slotPath path, $slot
    $slot.addClass 'slotter'
    $slot.attr 'href', url
    $slot.data "url", url
    this[0].href = url # that's where handleRemote gets the url from
                       # .attr(href, url) only works for anchors
    $slot.data "remote", true
    $.rails.handleRemote($slot)

  setSlotContent: (val, mode, $slotter) ->
    v = $(val)[0] && $(val) || val

    if typeof(v) == "string"
      # Needed to support "TEXT: result" pattern in success (eg deleting nested cards)
      @slot("success", mode).replaceWith v
    else
      if v.hasClass("_overlay")
        mode = "overlay"
      else if v.hasClass("_modal")
        mode = "modal"
      @slot("success", mode).setSlotContentFromElement v, mode, $slotter
    v

  setSlotContentFromElement: (el, mode, $slotter) ->
    s = $(this)

    if mode == "overlay"
      s.addOverlay(el)
    else if el.hasClass("_modal-slot") or mode == "modal"
      el = el.modalify($slotter)
      $("body > ._modal-slot").replaceWith el
      el.modal("show", $slotter)
    else
      s.replaceWith el

    el.triggerSlotReady($slotter)

  triggerSlotReady: (slotter) ->
    @trigger "slotReady", slotter
    @find(".card-slot").trigger "slotReady", slotter

  addOverlay: (overlay) ->
    if @parent().hasClass("overlay-container")
      if $(overlay).hasClass("_stack-overlay")
        @before overlay
      else
        @parent().find("._overlay").replaceWith overlay
    else
      @find(".tinymce-textarea").each ->
        tinyMCE.execCommand('mceRemoveControl', false, $(this).attr("id"))
      @wrapAll('<div class="overlay-container">')
      @addClass("_bottomlay-slot")
      @before overlay

  removeOverlay: () ->
    if @siblings().length == 1
      bottomlay = $(@siblings()[0])
      if bottomlay.hasClass("_bottomlay-slot")
        bottomlay.unwrap().removeClass("_bottomlay-slot").updateBridge(true, bottomlay)
        bottomlay.find(".tinymce-textarea").each ->
          decko.initTinyMCE($(this).attr("id"))

    @remove()


  modalify: ($slotter) ->
    if $slotter.data("modal-body")?
      @find(".modal-body").append($slotter.data("modal-body"))
    if @hasClass("_modal-slot")
      this
    else
      modalSlot = $('<div/>', id: "modal-container", class: "modal fade _modal-slot")
      modalSlot.append($('<div/>' , class: "modal-dialog"))
               .append($('<div/>', class: "modal-content"))
               .append(this)
      modalSlot

  # overlayClosed=true means the bridge update was
  # triggered by closing an overly
  updateBridge: (overlayClosed=false, slotter) ->
    return unless @closest(".bridge").length > 0
    if @data("breadcrumb")
      @updateBreadcrumb()
    else if slotter and $(slotter).data("breadcrumb")
      $(slotter).updateBreadcrumb()

    if overlayClosed
      $(".bridge-pills > .nav-item > .nav-link.active").removeClass("active")

  updateBreadcrumb: () ->
    bc_item = $(".modal-header ._bridge-breadcrumb li:last-child")
    bc_item.text(this.data("breadcrumb"))
    bc_item.attr("class", "breadcrumb-item active #{this.data('breadcrumb-class')}")


  # mode can be "standard", "overlay" or "modal"
  slotSuccess: (data, $slotter) ->
    mode = $slotter.data("slotter-mode")
    if mode == "silent-success"
      return
    else if data.redirect
      window.location=data.redirect
    else
      notice = @attr('notify-success')
      mode ||= "standard"
      newslot = @setSlotContent data, mode, $slotter

      if newslot.jquery # sometimes response is plaintext
        decko.initializeEditors newslot
        if notice?
          newslot.notify notice, "success"

  slotError: (status, result) ->
    if status == 403 #permission denied
      @setSlotContent result
    else
      @notify result, "error"
      if status == 409 #edit conflict
        @slot().find('.current_revision_id').val(
          @slot().find('.new-current-revision-id').text()
        )
      else if status == 449
        @slot().find('g-recaptcha').reloadCaptcha()
}
